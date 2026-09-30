require "rails_helper"

RSpec.describe "Api::V1::Notifications", type: :request do
  let(:user) { create(:user) }

  describe "GET /api/v1/notifications" do
    it "returns only the current user's notifications" do
      mine = create(:notification, user: user)
      create(:notification)

      get "/api/v1/notifications", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(json["notifications"].map { |n| n["id"] }).to eq([ mine.id ])
    end

    it "filters to unread only" do
      unread = create(:notification, user: user, read_at: nil)
      create(:notification, user: user, read_at: Time.current)

      get "/api/v1/notifications", params: { unread: "true" }, headers: auth_headers(user)

      expect(json["notifications"].map { |n| n["id"] }).to eq([ unread.id ])
    end
  end

  describe "PATCH /api/v1/notifications/:id/read" do
    it "marks the notification read" do
      notification = create(:notification, user: user, read_at: nil)

      patch "/api/v1/notifications/#{notification.id}/read", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(notification.reload.read_at).to be_present
    end

    it "forbids marking someone else's notification as read" do
      notification = create(:notification, read_at: nil)

      patch "/api/v1/notifications/#{notification.id}/read", headers: auth_headers(user)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/v1/notifications/read_all" do
    it "marks all of the current user's unread notifications as read" do
      create_list(:notification, 2, user: user, read_at: nil)

      post "/api/v1/notifications/read_all", headers: auth_headers(user)

      expect(response).to have_http_status(:no_content)
      expect(user.notifications.unread.count).to eq(0)
    end
  end
end
