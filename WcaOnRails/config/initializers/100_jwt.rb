# frozen_string_literal: true

# This needs to be run before the devise.rb initializer
require_relative '../../app/helpers/jwt_options'

JwtOptions.secret = EnvVars.DEVISE_JWT_SECRET_KEY
# Default algorithm for Devise-jwt
JwtOptions.algorithm = 'HS256'
# The expiry time we define in the monolith
JwtOptions.expiry = 30.minutes.to_i
