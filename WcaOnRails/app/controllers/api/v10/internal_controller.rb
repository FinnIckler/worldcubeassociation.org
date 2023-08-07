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
end
