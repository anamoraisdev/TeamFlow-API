require "rails_helper"

RSpec.describe "Api::V1::Teams", type: :request do
  let(:user) { create(:user) }

  describe "GET /api/v1/teams" do
    it "requires authentication" do
      get "/api/v1/teams"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns only the teams the user belongs to" do
      own_team = create(:team)
      create(:team_membership, team: own_team, user: user)
      create(:team) # unrelated team

      get "/api/v1/teams", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(json["teams"].map { |t| t["id"] }).to eq([ own_team.id ])
      expect(json["meta"]).to include("page", "count", "pages")
    end
  end

  describe "POST /api/v1/teams" do
    it "creates a team and makes the creator its owner" do
      post "/api/v1/teams", params: { team: { name: "Squad Alpha" } }, headers: auth_headers(user)

      expect(response).to have_http_status(:created)
      team = Team.find(json["id"])
      expect(user.role_in(team)).to eq("owner")
    end
  end

  describe "GET /api/v1/teams/:id" do
    it "returns 404 with a standard error envelope for a non-member" do
      team = create(:team)

      get "/api/v1/teams/#{team.id}", headers: auth_headers(user)

      expect(response).to have_http_status(:forbidden)
      expect(json["error"]["code"]).to eq("forbidden")
    end
  end

  describe "DELETE /api/v1/teams/:id" do
    it "forbids a non-owner from deleting the team" do
      team = create(:team)
      create(:team_membership, team: team, user: user, role: :admin)

      delete "/api/v1/teams/#{team.id}", headers: auth_headers(user)

      expect(response).to have_http_status(:forbidden)
    end

    it "allows the owner to delete the team" do
      team = create(:team)
      create(:team_membership, team: team, user: user, role: :owner)

      delete "/api/v1/teams/#{team.id}", headers: auth_headers(user)

      expect(response).to have_http_status(:no_content)
      expect(Team.exists?(team.id)).to be(false)
    end
  end
end
