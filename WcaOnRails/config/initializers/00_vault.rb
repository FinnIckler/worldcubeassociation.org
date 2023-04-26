# frozen_string_literal: true

require "vault"

Vault.configure do |config|
  # The address of the Vault server, also read as ENV["VAULT_ADDR"]
  config.address = ENV.fetch("VAULT_ADDR", "http://localhost:8200")

  # The token to authenticate with Vault, also read as ENV["VAULT_TOKEN"]
  config.token = ENV.fetch("VAULT_TOKEN", ENV["VAULT_DEV_ROOT_TOKEN_ID"])
  # Optional - if using the Namespace enterprise feature
  # config.namespace   = "my-namespace" # Also reads from ENV["VAULT_NAMESPACE"]


  # Use SSL verification, also read as ENV["VAULT_SSL_VERIFY"]
  config.ssl_verify = false

  # Timeout the connection after a certain amount of time (seconds), also read
  # as ENV["VAULT_TIMEOUT"]
  config.timeout = 30

  # It is also possible to have finer-grained controls over the timeouts, these
  # may also be read as environment variables
  config.ssl_timeout  = 5
  config.open_timeout = 5
  config.read_timeout = 30
end


# Read a secret from Vault.
def read_secret(secret_name)
  Vault.with_retries(Vault::HTTPConnectionError, Vault::HTTPError) do |attempt, e|
    if e
      log "Received exception #{e} from Vault - attempt #{attempt}"
    end
    secret = Vault.logical.read("secret/data/#{secret_name}")
    if secret.present?
      secret.data[:data][:value]
    else # TODO should we hard error out here?
      log "Tried to read #{secret_name}, but doesn´t exist"
      ""
    end
  end
end

def create_secret(secret_name, value)
  Vault.with_retries(Vault::HTTPConnectionError) do
    Vault.logical.write("secret/data/#{secret_name}", data: { value: value })
  end
end

# Initialize secrets for dev and test
def init
  create_secret("GOOGLE_MAPS_API_KEY","AIzaSyDYBIU04Tv_j914utSX9OJhJDxi7eiZ84w")
  create_secret("STRIPE_API_KEY", "sk_test_CY2eQJchZKUrPGQtJ3Z60ycA")
  create_secret("STRIPE_PUBLISHABLE_KEY", "pk_test_N0KdZIOedIrP8C4bD5XLUxOY")
  create_secret("STRIPE_CLIENT_ID","ca_A2YDwmyOll0aORNYiOA41dzEWn4xIDS2")
  create_secret("OTP_ENCRYPTION_KEY","abcdefghijklmnopqrstuvwxyz1234567890")
  create_secret("DISCOURSE_SECRET","myawesomesharedsecret")
  create_secret("SURVEY_SECRET","wacdoesnotknowthis")
  create_secret("ACTIVERECORD_PRIMARY_KEY","abcdefghijklmnopqrstuvwxyz1234567890")
  create_secret("ACTIVERECORD_DETERMINISTIC_KEY","abcdefghijklmnopqrstuvwxyz1234567890")
  create_secret("ACTIVERECORD_KEY_DERIVATION_SALT","abcdefghijklmnopqrstuvwxyz1234567890")
  create_secret("SECRET_KEY_BASE","a003fdc6f113ff7d295596a02192c7116a76724ba6d3071043eefdd16f05971be0dc58f244e67728757b2fb55ae7a41e1eb97c1fe247ddaeb6caa97cea32120c")
  create_secret("GITHUB_CREATE_PR_ACCESS_TOKEN", "")
end

unless Rails.env.production?
  init
end
