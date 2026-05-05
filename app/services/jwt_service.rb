class JwtService
  # We use your Rails app's built-in master key to cryptographically sign the tokens.
  # This ensures that if someone tampers with the token, the signature will break.
  SECRET_KEY = Rails.application.credentials.secret_key_base.to_s

  # Encodes a payload into a JWT. 
  # We enforce our 15-minute access token lifespan here.
  def self.encode(payload, exp = 15.minutes.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  # Decodes a JWT and turns the payload back into a Ruby hash.
  # If the token is expired, the jwt gem will automatically throw a JWT::ExpiredSignature error
  # which we are already rescuing in our ApplicationController!
  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(decoded)
  end
end