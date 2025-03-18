# frozen_string_literal: true

require "csv"

class RegistrationsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :psych_sheet, :psych_sheet_event, :register, :stripe_webhook, :payment_denomination]
  # Stripe has its own authenticity mechanism with Webhook Secrets.
  protect_from_forgery except: [:stripe_webhook]

  private def competition_from_params
    competition = if params[:competition_id]
                    Competition.find(params[:competition_id])
                  else
                    Registration.find(params[:id]).competition
                  end
    unless competition.user_can_view?(current_user)
      raise ActionController::RoutingError.new('Not Found')
    end
    competition
  end

  before_action -> { redirect_to_root_unless_user(:can_manage_competition?, competition_from_params) },
                except: [:index, :psych_sheet, :psych_sheet_event, :register, :payment_completion, :load_payment_intent, :stripe_webhook, :payment_denomination, :capture_paypal_payment]

  before_action :competition_must_be_using_wca_registration!, except: [:import, :do_import, :add, :do_add, :index, :psych_sheet, :psych_sheet_event, :stripe_webhook, :payment_denomination]
  private def competition_must_be_using_wca_registration!
    if !competition_from_params.use_wca_registration?
      flash[:danger] = I18n.t('registrations.flash.not_using_wca')
      redirect_to competition_path(competition_from_params)
    end
  end

  before_action :competition_must_not_be_using_wca_registration!, only: [:import, :do_import]
  private def competition_must_not_be_using_wca_registration!
    if competition_from_params.use_wca_registration?
      redirect_to competition_path(competition_from_params)
    end
  end

  def edit_registrations
    @competition = competition_from_params
  end

  def psych_sheet
    @competition = competition_from_params
    most_main_event = @competition.events.min_by(&:rank)
    redirect_to competition_psych_sheet_event_url(@competition.id, most_main_event.id)
  end

  def psych_sheet_event
    @competition = competition_from_params
    @event = Event.c_find(params[:event_id])
    if @competition.results_posted?
      render :psych_results_posted
      return
    end

    @psych_sheet = @competition.psych_sheet_event(@event, params[:sort_by])
  end

  def index
    @competition = competition_from_params
    @registrations = @competition.registrations.accepted.includes(:user, :events).order("users.name")
    @count_by_event = Hash.new(0)
    @newcomers = @returners = 0
  end

  def edit
    @competition = Competition.find(params[:competition_id])
    @user = User.find(params[:user_id])
  end

  def import
    @competition = competition_from_params
  end

  def do_import
    competition = competition_from_params
    file = params[:registrations_import][:registrations_file]
    required_columns = ["status", "name", "country", "wca id", "birth date", "gender", "email"] + competition.events.map(&:id)
    # Ensure the CSV file includes all required columns.
    headers = CSV.read(file.path).first.compact.map(&:downcase)
    missing_headers = required_columns - headers
    if missing_headers.any?
      raise I18n.t("registrations.import.errors.missing_columns", columns: missing_headers.join(", "))
    end
    registration_rows = CSV.read(file.path, headers: true, header_converters: :symbol, skip_blanks: true, converters: ->(string) { string&.strip })
                           .map(&:to_hash)
                           .select { |registration_row| registration_row[:status] == "a" }
    if competition.competitor_limit_enabled? && registration_rows.length > competition.competitor_limit
      raise I18n.t("registrations.import.errors.over_competitor_limit",
                   accepted_count: registration_rows.length,
                   limit: competition.competitor_limit)
    end
    emails = registration_rows.map { |registration_row| registration_row[:email] }
    email_duplicates = emails.select { |email| emails.count(email) > 1 }.uniq
    if email_duplicates.any?
      raise I18n.t("registrations.import.errors.email_duplicates", emails: email_duplicates.join(", "))
    end
    wca_ids = registration_rows.map { |registration_row| registration_row[:wca_id] }
    wca_id_duplicates = wca_ids.select { |wca_id| wca_ids.count(wca_id) > 1 }.uniq
    if wca_id_duplicates.any?
      raise I18n.t("registrations.import.errors.wca_id_duplicates", wca_ids: wca_id_duplicates.join(", "))
    end
    raw_dobs = registration_rows.map { |registration_row| registration_row[:birth_date] }
    wrong_format_dobs = raw_dobs.select { |raw_dob| Date.safe_parse(raw_dob)&.to_fs != raw_dob }
    if wrong_format_dobs.any?
      raise I18n.t("registrations.import.errors.wrong_dob_format", raw_dobs: wrong_format_dobs.join(", "))
    end
    new_locked_users = []
    # registered_at stores millisecond precision, but we want all registrations
    #   from CSV import to be considered as one "batch". So we mark a timestamp
    #   once, and then reuse it throughout the loop.
    import_time = Time.now.utc
    ActiveRecord::Base.transaction do
      competition.registrations.accepted.each do |registration|
        unless emails.include?(registration.user.email)
          registration.update!(competing_status: Registrations::Helper::STATUS_CANCELLED)
        end
      end
      registration_rows.each do |registration_row|
        user, locked_account_created = user_for_registration!(registration_row)
        new_locked_users << user if locked_account_created
        registration = competition.registrations.find_or_initialize_by(user_id: user.id) do |reg|
          reg.registered_at = import_time
        end
        unless registration.accepted?
          registration.assign_attributes(competing_status: Registrations::Helper::STATUS_ACCEPTED)
        end
        registration.registration_competition_events = []
        competition.competition_events.map do |competition_event|
          value = registration_row[competition_event.event_id.to_sym]
          if value == "1"
            registration.registration_competition_events.build(competition_event_id: competition_event.id)
          elsif value != "0"
            raise I18n.t("registrations.import.errors.invalid_event_column", value: value, column: competition_event.event_id)
          end
        end
        registration.save!
        registration.add_history_entry({ event_ids: registration.event_ids }, "user", current_user.id, "CSV Import")
      rescue StandardError => e
        raise e.exception(I18n.t("registrations.import.errors.error", registration: registration_row[:name], error: e))
      end
    end
    new_locked_users.each do |user|
      RegistrationsMailer.notify_registrant_of_locked_account_creation(user, competition).deliver_later
    end
    flash[:success] = I18n.t("registrations.flash.imported")
    redirect_to competition_registrations_import_url(competition)
  rescue StandardError => e
    flash[:danger] = e.to_s
    redirect_to competition_registrations_import_url(competition)
  end

  def add
    @competition = competition_from_params
  end

  def do_add
    @competition = competition_from_params
    if @competition.registration_full?
      flash[:danger] = I18n.t("registrations.mailer.deleted.causes.registrations_full")
      redirect_to competition_path(@competition)
      return
    end
    ActiveRecord::Base.transaction do
      user, locked_account_created = user_for_registration!(params[:registration_data])
      registration = @competition.registrations.find_or_initialize_by(user_id: user.id) do |reg|
        reg.registered_at = Time.now.utc
      end
      raise I18n.t("registrations.add.errors.already_registered") unless registration.new_record?
      registration_comment = params.dig(:registration_data, :comments)
      registration.assign_attributes(comments: registration_comment) if registration_comment.present?
      registration.assign_attributes(competing_status: Registrations::Helper::STATUS_ACCEPTED)
      params[:registration_data][:event_ids]&.each do |event_id|
        competition_event = @competition.competition_events.find { |ce| ce.event_id == event_id }
        registration.registration_competition_events.build(competition_event_id: competition_event.id)
      end
      registration.save!
      registration.add_history_entry({ event_ids: registration.event_ids }, "user", current_user.id, "OTS Form")
      if locked_account_created
        RegistrationsMailer.notify_registrant_of_locked_account_creation(user, @competition).deliver_later
      end
    end
    flash[:success] = I18n.t("registrations.flash.added")
    redirect_to competition_registrations_add_url(@competition)
  rescue StandardError => e
    flash.now[:danger] = e.to_s
    render :add
  end

  private def user_for_registration!(registration_row)
    registration_row[:wca_id]&.upcase!
    registration_row[:email]&.downcase!
    person_details = {
      name: registration_row[:name],
      country_iso2: Country.c_find(registration_row[:country]).iso2,
      gender: registration_row[:gender],
      dob: registration_row[:birth_date],
    }
    if registration_row[:wca_id].present?
      unless Person.exists?(wca_id: registration_row[:wca_id])
        raise I18n.t("registrations.import.errors.non_existent_wca_id", wca_id: registration_row[:wca_id])
      end
      user = User.find_by(wca_id: registration_row[:wca_id])
      if user
        if user.dummy_account?
          email_user = User.find_by(email: registration_row[:email])
          if email_user
            if email_user.wca_id.present?
              raise I18n.t("registrations.import.errors.email_user_with_different_wca_id",
                           email: registration_row[:email], user_wca_id: email_user.wca_id,
                           registration_wca_id: registration_row[:wca_id])
            else
              # User hooks will also remove the dummy user account.
              email_user.update!(wca_id: registration_row[:wca_id], **person_details)
              [email_user, false]
            end
          else
            user.skip_reconfirmation!
            user.update!(dummy_account: false, **person_details, email: registration_row[:email])
            [user, true]
          end
        else
          [user, false] # Use this account.
        end
      else
        email_user = User.find_by(email: registration_row[:email])
        if email_user
          if email_user.unconfirmed_wca_id.present? && email_user.unconfirmed_wca_id != registration_row[:wca_id]
            raise I18n.t("registrations.import.errors.email_user_with_different_unconfirmed_wca_id",
                         email: registration_row[:email], unconfirmed_wca_id: email_user.unconfirmed_wca_id,
                         registration_wca_id: registration_row[:wca_id])
          else
            email_user.update!(wca_id: registration_row[:wca_id], **person_details)
            [email_user, false]
          end
        else
          # Create a locked account with confirmed WCA ID.
          [create_locked_account!(registration_row), true]
        end
      end
    else
      email_user = User.find_by(email: registration_row[:email])
      # Use the user if exists, otherwise create a locked account without WCA ID.
      if email_user
        unless email_user.wca_id.present?
          # If this is just a user account with no WCA ID, update its data.
          # Given it's verified by organizers, it's more trustworthy/official data (if different at all).
          email_user.update!(person_details)
        end
        [email_user, false]
      else
        [create_locked_account!(registration_row), true]
      end
    end
  end

  private def create_locked_account!(registration_row)
    User.new_locked_account(
      name: registration_row[:name],
      email: registration_row[:email],
      wca_id: registration_row[:wca_id],
      country_iso2: Country.c_find(registration_row[:country]).iso2,
      gender: registration_row[:gender],
      dob: registration_row[:birth_date],
    ).tap { |user| user.save! }
  end

  def register
    @competition = competition_from_params
    @is_processing = current_user.present? && (Rails.cache.read(CacheAccess.registration_processing_cache_key(@competition.id, current_user.id)) || false)
  end

  def payment_denomination
    ruby_denomination = params.require(:amount)
    currency_iso = params.require(:currency_iso)

    ruby_money = Money.new(ruby_denomination, currency_iso)
    human_amount = helpers.format_money(ruby_money)

    api_amounts = {
      stripe: StripeRecord.amount_to_stripe(ruby_denomination, currency_iso),
      paypal: PaypalRecord.amount_to_paypal(ruby_denomination, currency_iso),
    }

    render json: { api_amounts: api_amounts, human_amount: human_amount }
  end

  # Respond to asynchronous payment updates from Stripe.
  # Code skeleton according to https://stripe.com/docs/webhooks/quickstart
  def stripe_webhook
    payload = request.raw_post

    begin
      event = Stripe::Event.construct_from(
        JSON.parse(payload, symbolize_names: true),
      )
    rescue JSON::ParserError => e
      # Invalid payload
      logger.warn "Stripe webhook error while parsing basic request. #{e.message}"
      return head :bad_request
    end
    # Check if webhook signing is configured.
    if AppSecrets.STRIPE_WEBHOOK_SECRET.present?
      # Retrieve the event by verifying the signature using the raw body and secret.
      signature = request.env['HTTP_STRIPE_SIGNATURE']
      begin
        event = Stripe::Webhook.construct_event(
          payload, signature, AppSecrets.STRIPE_WEBHOOK_SECRET
        )
      rescue Stripe::SignatureVerificationError => e
        logger.warn "Stripe webhook signature verification failed. #{e.message}"
        return head :bad_request
      end
    elsif Rails.env.production? && EnvConfig.WCA_LIVE_SITE?
      logger.error "No Stripe webhook secret defined in Production."
      return head :bad_request
    end

    # Create a default audit that marks the event as "unhandled".
    audit_event = StripeWebhookEvent.create_from_api(event)
    audit_remote_timestamp = audit_event.created_at_remote

    stripe_intent = event.data.object # contains a polymorphic type that depends on the event
    stored_record = StripeRecord.find_by(stripe_id: stripe_intent.id)

    if StripeWebhookEvent::HANDLED_EVENTS.include?(event.type)
      if stored_record.nil?
        logger.error "Stripe webhook reported event on entity #{stripe_intent.id} but we have no matching transaction."
        return head :not_found
      else
        audit_event.update!(stripe_record: stored_record, handled: true)
      end
    end

    connected_account = ConnectedStripeAccount.find_by(account_id: stored_record.account_id)

    unless connected_account.present?
      logger.error "Stripe webhook reported event for account '#{stored_record.account_id}' but we are not connected to that account."
      return head :not_found
    end

    # Handle the event
    case event.type
    when StripeWebhookEvent::PAYMENT_INTENT_SUCCEEDED
      # stripe_intent contains a Stripe::PaymentIntent as per Stripe documentation

      stored_intent = stored_record.payment_intent

      stored_intent.update_status_and_charges(connected_account, stripe_intent, audit_event, audit_remote_timestamp) do |charge_transaction|
        ruby_money = charge_transaction.money_amount
        stored_holder = stored_intent.holder

        if stored_holder.is_a? Registration
          stored_payment = stored_holder.record_payment(
            ruby_money.cents,
            ruby_money.currency.iso_code,
            charge_transaction,
            stored_intent.initiated_by_id,
          )

          # Webhooks are running in async mode, so we need to rely on the creation timestamp sent by Stripe.
          # Context: When our servers die due to traffic spikes, the Stripe webhook cannot be processed
          #   and Stripe tries again after an exponential backoff. So we (erroneously!) record the creation timestamp
          #   in our DB _after_ the backed-off event has been processed. This can lead to a wrong registration order :(
          stored_payment.update!(created_at: audit_remote_timestamp)
        end
      end
    when StripeWebhookEvent::PAYMENT_INTENT_CANCELED
      # stripe_intent contains a Stripe::PaymentIntent as per Stripe documentation

      stored_intent = stored_record.payment_intent
      stored_intent.update_status_and_charges(connected_account, stripe_intent, audit_event, audit_remote_timestamp)
    else
      logger.info "Unhandled Stripe event type: #{event.type}"
    end

    head :ok
  end

  def payment_completion
    # Provided by Stripe upon redirect when the "PaymentElement" workflow is completed
    competition_id = params[:competition_id]
    competition = Competition.find(competition_id)

    payment_integration = params[:payment_integration].to_sym
    payment_account = competition.payment_account_for(payment_integration)

    unless payment_account.present?
      flash[:danger] = t("registrations.payment_form.errors.cpi_disconnected")
      return redirect_to competition_register_path(competition)
    end

    stored_record, secret_check = payment_account.find_payment_from_request(params)

    unless stored_record.present?
      flash[:error] = t("registrations.payment_form.errors.generic.not_found", provider: t("payments.payment_providers.#{payment_integration}"))
      return redirect_to competition_register_path(competition)
    end

    stored_intent = stored_record.payment_intent

    unless stored_intent.present?
      flash[:error] = t("registrations.payment_form.errors.generic.intent_not_found", provider: t("payments.payment_providers.#{payment_integration}"))
      return redirect_to competition_register_path(competition)
    end

    # Some API gateways like Stripe provide the client_secret as a kind of "checksum" (or fraud protection)
    #   back to us upon redirect. Other providers (like PayPal…) unfortunately don't.
    #   So we only compare this secret value with our stored intent record if it's actually provided to us
    if secret_check.present? && stored_intent.client_secret != secret_check
      flash[:error] = t("registrations.payment_form.errors.generic.secret_invalid", provider: t("payments.payment_providers.#{payment_integration}"))
      return redirect_to competition_register_path(competition)
    end

    remote_intent = stored_intent.retrieve_remote

    unless remote_intent.present?
      flash[:error] = t("registrations.payment_form.errors.generic.remote_not_found", provider: t("payments.payment_providers.#{payment_integration}"))
      return redirect_to competition_register_path(competition)
    end

    registration = stored_intent.holder

    stored_intent.update_status_and_charges(payment_account, remote_intent, current_user) do |charge_transaction|
      ruby_money = charge_transaction.money_amount

      registration.record_payment(
        ruby_money.cents,
        ruby_money.currency.iso_code,
        charge_transaction,
        current_user.id,
      )

      # Running in sync mode, so if the code reaches this point we're reasonably confident that the time the Stripe payment
      #   succeeded matches the time that the information reached our database. There are cases for async webhooks where
      #   this behavior differs and we overwrite created_at manually, see #stripe_webhook above.
    end

    # For details on what the individual statuses mean, please refer to the comments
    #   of the `enum :wca_status` declared in the `payment_intent.rb` model
    case stored_intent.wca_status
    when PaymentIntent.wca_statuses[:succeeded]
      flash[:success] = t("registrations.payment_form.payment_successful")
    when PaymentIntent.wca_statuses[:pending]
      flash[:warning] = t("registrations.payment_form.errors.payment_pending")
    when PaymentIntent.wca_statuses[:created]
      flash[:error] = t("registrations.payment_form.errors.payment_reset")
    when PaymentIntent.wca_statuses[:processing]
      flash[:warning] = t("registrations.payment_form.payment_processing")
    when PaymentIntent.wca_statuses[:partial]
      flash[:warning] = t("registrations.payment_form.payment_partial")
    when PaymentIntent.wca_statuses[:failed]
      flash[:error] = t("registrations.payment_form.errors.payment_failed")
    when PaymentIntent.wca_statuses[:canceled]
      flash[:error] = t("registrations.payment_form.errors.payment_canceled")
    else
      # Invalid status
      flash[:error] = "Invalid PaymentIntent status"
    end

    redirect_to competition_register_path(competition_id)
  end

  def load_payment_intent
    registration = Registration.includes(:competition).find(params[:id])

    unless registration.user_id == current_user.id
      return render status: :forbidden, json: { error: { message: t("registrations.payment_form.errors.not_allowed") } }
    end

    amount = params[:amount].to_i

    if registration.outstanding_entry_fees.cents <= 0
      return render status: :bad_request, json: { error: { message: t("registrations.payment_form.errors.already_paid") } }
    end

    if amount < registration.outstanding_entry_fees.cents
      return render status: :bad_request, json: { error: { message: t("registrations.payment_form.alerts.amount_too_low") } }
    end

    competition = registration.competition

    payment_integration = params.require(:payment_integration).to_sym
    return head :forbidden if payment_integration == :paypal && PaypalInterface.paypal_disabled?

    payment_account = competition.payment_account_for(payment_integration)
    intent = payment_account.prepare_intent(registration, amount, competition.currency_code, current_user)

    render json: { client_secret: intent.client_secret }
  end

  def refund_payment
    competition_id = params[:competition_id]
    competition = Competition.find(competition_id)

    payment_integration = params[:payment_integration].to_sym
    payment_account = competition.payment_account_for(payment_integration)

    unless payment_account.present?
      flash[:danger] = "You cannot issue a refund for this competition anymore. Please use your payment provider's dashboard to do so."
      return redirect_to competition_registrations_path(competition)
    end

    payment_record = payment_account.find_payment(params[:payment_id])

    registration = payment_record.root_record.payment_intent.holder

    redirect_path = edit_registration_v2_path(competition_id, registration.user_id)

    refund_amount_param = params.require(:payment).require(:refund_amount)
    refund_amount = refund_amount_param.to_i
    amount_left = payment_record.ruby_amount_available_for_refund - refund_amount

    if amount_left.negative?
      flash[:danger] = "You are not allowed to refund more than the competitor has paid."
      return redirect_to redirect_path
    end

    if refund_amount.negative?
      flash[:danger] = "The refund amount must be greater than zero."
      return redirect_to redirect_path
    end

    refund_receipt = payment_account.issue_refund(payment_record, refund_amount)

    # Should be the same as `refund_amount`, but by double-converting from the Payment Gateway object
    # we can also double-check that they're on the same page as we are (to be _really_ sure!)
    ruby_money = refund_receipt.money_amount

    registration.record_refund(
      ruby_money.cents,
      ruby_money.currency.iso_code,
      refund_receipt,
      payment_record.registration_payment.id,
      current_user.id,
    )

    flash[:success] = 'Payment was refunded'
    redirect_to redirect_path
  end

  private def registration_from_params
    id = params.require(:id)
    Registration.find(id)
  end

  def capture_paypal_payment
    return head :forbidden if PaypalInterface.paypal_disabled?

    registration = registration_from_params

    competition = registration.competition
    paypal_integration = competition.payment_account_for(:paypal)

    order_id = params.require(:orderID)

    response = PaypalInterface.capture_payment(paypal_integration.paypal_merchant_id, order_id)
    if response['status'] == 'COMPLETED'

      # TODO: Handle the case where there are multiple captures for a payment
      # 1) Multiple installments
      # 2) Some failed, some succeeded

      amount_details = response['purchase_units'][0]['payments']['captures'][0]['amount']
      currency_code = amount_details['currency_code']
      amount = PaypalRecord.amount_to_ruby(amount_details["value"], currency_code)
      order_record = PaypalRecord.find_by(paypal_id: response["id"]) # TODO: Add error handling for the PaypalRecord not being found

      # Create a Capture object and link it to the PaypalRecord
      # NOTE: This assumes there is only ONE capture per order - not a valid long-term assumption
      capture_from_response = response['purchase_units'][0]['payments']['captures'][0]

      capture_record = PaypalRecord.create_from_api(
        capture_from_response,
        :capture,
        {}, # TODO: Refactor so that we can actually capture the payload? Perhaps this needs to be called in PaypalInterface?,
        paypal_integration.paypal_merchant_id,
        order_record,
      )

      # Record the payment
      registration.record_payment(
        amount,
        currency_code,
        capture_record,
        current_user.id,
      )
    end

    render json: response
  end
end
