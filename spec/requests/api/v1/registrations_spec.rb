require "rails_helper"

RSpec.describe "Api::V1::Registrations", type: :request do
  describe "POST /api/v1/signup" do
    it "creates a user and returns a token" do
      post "/api/v1/signup", params: { user: { name: "Ana", email: "ana@example.com", password: "password123" } }

      expect(response).to have_http_status(:created)
      expect(json["token"]).to be_present
      expect(json["user"]["email"]).to eq("ana@example.com")
    end

    it "returns a standardized validation error when invalid" do
      post "/api/v1/signup", params: { user: { name: "", email: "not-an-email", password: "short" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["error"]["code"]).to eq("validation_failed")
      expect(json["error"]["details"]).to include("name", "email", "password")
    end

    it "rejects a duplicate email" do
      create(:user, email: "ana@example.com")

      post "/api/v1/signup", params: { user: { name: "Ana", email: "ana@example.com", password: "password123" } }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
