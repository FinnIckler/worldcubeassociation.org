# frozen_string_literal: true
require 'jwt'
require_relative '../../../helpers/jwt_options'
require_relative '../../../helpers/error_codes'
class Api::V10::InternalController < Api::V10::ApiController
  prepend_before_action :validate_token
  skip_before_action :validate_token, only: [:payment_init, :payment_finish]
  # just for testing
  protect_from_forgery if: -> { current_user.present? }, with: :exception
  # TODO: Switch this to Vault Identity Tokens
  def validate_token
    auth_header = request.headers["Authorization"]
    unless auth_header.present?
      return render json: { error: ErrorCodes::MISSING_AUTHENTICATION }, status: :forbidden
    end
    token = request.headers["Authorization"].split[1]
    begin
      @decoded_token = (JWT.decode token, EnvVars.DEVISE_JWT_SECRET_KEY, true, { algorithm: JwtOptions.algorithm })[0]
    rescue JWT::VerificationError, JWT::InvalidJtiError
      render json: { error: ErrorCodes::INVALID_TOKEN }, status: :forbidden
    rescue JWT::ExpiredSignature
      render json: { error: ErrorCodes::EXPIRED_TOKEN }, status: :forbidden
    end
  end

  def permissions
    user_id = params.require(:user_id)
    user = User.find(user_id)
    render json: {
      can_attend_competitions: {
        scope: user.cannot_register_for_competition_reasons.empty? ? "*" : [],
      },
      can_organize_competitions: {
        scope: user.can_create_competitions? ? "*" : [],
      },
      can_administer_competitions: {
        scope: user.can_admin_competitions? ? "*" : (user.delegated_competitions + user.organized_competitions).pluck("id"),
      },
    }
  end

  def payment_init
    competition_id, user_id = params["attendee_id"].split("-")

    amount = params["amount"].to_i

    competition = Competition.find(competition_id)
    user = User.find(user_id)
    account_id = competition.connected_stripe_account_id

    registration_metadata = {
      competition: competition.name,
      registration_url: "https://www.worldcubeassociation.org/competitions/#{competition_id}/#{user_id}/edit",
    }

    currency_iso = params["currency_code"]
    stripe_amount = StripeTransaction.amount_to_stripe(amount, currency_iso)

    payment_intent_args = {
      amount: stripe_amount,
      currency: currency_iso,
      receipt_email: user.email,
      description: "Registration payment for #{competition.name}",
      metadata: registration_metadata,
    }

    # The Stripe API forces the user to provide a return_url when using automated payment methods.
    # In our test suite however, we want to be able to confirm specific payment methods without a return URL
    # because our CI containers are not exposed to the public. So we need this little hack :/
    enable_automatic_pm = !Rails.env.test?

    # we cannot recycle an existing intent, so we create a new one which needs all possible PaymentMethods enabled.
    # Required as per https://stripe.com/docs/payments/accept-a-payment-deferred?type=payment&client=html#create-intent
    payment_intent_args[:automatic_payment_methods] = { enabled: enable_automatic_pm }

    # Create the PaymentIntent, overriding the stripe_account for the request
    # by the connected stripe account for the competition.
    intent = Stripe::PaymentIntent.create(
      payment_intent_args,
      stripe_account: account_id,
      )

    # Log the payment attempt. We register the payment intent ID to find it later after checkout completed.
    stripe_transaction = StripeTransaction.create_from_api(intent, payment_intent_args, account_id)

    # memoize the payment intent in our DB because payments are handled asynchronously
    # so we need to be able to retrieve this later at any time, even when our server crashes in the meantime…
    StripePaymentIntent.create!(
      holder: params["attendee_id"],
      stripe_transaction: stripe_transaction,
      client_secret: intent.client_secret,
      user: user,
      )

    render json: { client_secret: intent.client_secret, connected_account_id: account_id }
  end

  def payment_finish
    @competition = Competition.find(params[:competition_id])

    # Provided by Stripe upon redirect when the "PaymentElement" workflow is completed
    intent_id = params[:payment_intent]
    intent_secret = params[:payment_intent_client_secret]

    stored_transaction = StripeTransaction.find_by(stripe_id: intent_id)
    stored_intent = stored_transaction.stripe_payment_intent

    unless stored_intent.client_secret == intent_secret
      flash[:error] = t("registrations.payment_form.errors.stripe_secret_invalid")
      return redirect_to competition_register_path(@competition)
    end

    # No need to create a new intent here. We can just query the stored intent from Stripe directly.
    stripe_intent = stored_intent.retrieve_intent

    unless stripe_intent.present?
      flash[:error] = t("registrations.payment_form.errors.stripe_not_found")
      return redirect_to competition_register_path(@competition)
    end

    stored_intent.update_status_and_charges(stripe_intent, current_user) do |charge_transaction|
      ruby_money = charge_transaction.money_amount

      registration.record_payment(
        ruby_money.cents,
        ruby_money.currency.iso_code,
        charge_transaction,
        current_user.id,
        )
    end

    # Payment Intent lifecycle as per https://stripe.com/docs/payments/intents#intent-statuses
    case stored_transaction.status
    when 'succeeded'
      flash[:success] = t("registrations.payment_form.payment_successful")
    when 'requires_action'
      # Customer did not complete the payment
      # For example, 3DSecure could still be pending.
      flash[:warning] = t("registrations.payment_form.errors.payment_pending")
    when 'requires_payment_method'
      # Payment failed. If a payment fails, it is "reset" by Stripe,
      # so from our end it looks like it never even started (i.e. the customer didn't choose a payment method yet)
      flash[:error] = t("registrations.payment_form.errors.payment_reset")
    when 'processing'
      # The payment can be pending, for example bank transfers can take multiple days to be fulfilled.
      flash[:warning] = t("registrations.payment_form.payment_processing")
    else
      # Invalid status
      flash[:error] = "Invalid PaymentIntent status"
    end

    redirect_to competition_register_path(@competition)
  end
end
