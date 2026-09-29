require "rails_helper"

RSpec.describe "Api::V1::Sessions", type: :request do
  describe "POST /api/v1/login" do
    let!(:user) { create(:user, email: "ana@example.com", password: "password123") }

    it "returns a token for valid credentials" do
      post "/api/v1/login", params: { session: { email: "ana@example.com", password: "password123" } }

      expect(response).to have_http_status(:ok)
      expect(json["token"]).to be_present
    end

    it "returns a consistent error for invalid credentials" do
      post "/api/v1/login", params: { session: { email: "ana@example.com", password: "wrong" } }

      expect(response).to have_http_status(:unauthorized)
      expect(json["error"]["code"]).to eq("invalid_credentials")
    end
  end
end
