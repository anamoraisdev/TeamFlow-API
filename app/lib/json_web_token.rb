# Minimal JWT encode/decode wrapper.
#
# NOTE: this is a hand-rolled authentication mechanism, built intentionally
# for this portfolio project to demonstrate understanding of how token-based
# auth works under the hood (hashing, signing, expiration). In a production
# app this would typically be replaced by a maintained solution such as
# Devise + devise-jwt. See README for more context.
class JsonWebToken
  ALGORITHM = "HS256".freeze

  class << self
    def encode(payload, expires_in: 24.hours)
      payload = payload.dup
      payload[:exp] = expires_in.from_now.to_i
      JWT.encode(payload, secret_key, ALGORITHM)
    end

    def decode(token)
      decoded = JWT.decode(token, secret_key, true, algorithm: ALGORITHM).first
      ActiveSupport::HashWithIndifferentAccess.new(decoded)
    rescue JWT::DecodeError, JWT::ExpiredSignature
      nil
    end

    private

    def secret_key
      ENV.fetch("JWT_SECRET_KEY") { Rails.application.credentials.secret_key_base }
    end
  end
end
