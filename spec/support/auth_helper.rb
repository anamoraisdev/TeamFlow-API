module AuthHelper
  def auth_headers(user)
    token = JsonWebToken.encode({ user_id: user.id })
    { "Authorization" => "Bearer #{token}" }
  end

  def json
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
end
