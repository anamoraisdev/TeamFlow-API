require "rails_helper"

RSpec.describe "Api::V1::TeamMemberships", type: :request do
  let(:team) { create(:team) }
  let(:owner) { create(:user) }
  let(:member) { create(:user) }

  before { create(:team_membership, team: team, user: owner, role: :owner) }

  describe "POST /api/v1/teams/:team_id/memberships" do
    it "allows an owner to add an existing user to the team" do
      new_user = create(:user)

      post "/api/v1/teams/#{team.id}/memberships",
           params: { membership: { user_id: new_user.id, role: "member" } },
           headers: auth_headers(owner)

      expect(response).to have_http_status(:created)
      expect(new_user.role_in(team)).to eq("member")
    end

    it "rejects setting role to owner through this endpoint" do
      new_user = create(:user)

      post "/api/v1/teams/#{team.id}/memberships",
           params: { membership: { user_id: new_user.id, role: "owner" } },
           headers: auth_headers(owner)

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["error"]["details"]).to have_key("role")
    end

    it "forbids a plain member from adding others" do
      create(:team_membership, team: team, user: member, role: :member)
      new_user = create(:user)

      post "/api/v1/teams/#{team.id}/memberships",
           params: { membership: { user_id: new_user.id, role: "member" } },
           headers: auth_headers(member)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /api/v1/teams/:team_id/memberships" do
    it "filters by role" do
      create(:team_membership, team: team, user: member, role: :member)
      admin = create(:user)
      create(:team_membership, team: team, user: admin, role: :admin)

      get "/api/v1/teams/#{team.id}/memberships", params: { role: "admin" }, headers: auth_headers(owner)

      expect(json.map { |m| m["role"] }).to eq([ "admin" ])
    end

    it "returns a consistent error for an invalid role filter" do
      get "/api/v1/teams/#{team.id}/memberships", params: { role: "not_a_role" }, headers: auth_headers(owner)

      expect(response).to have_http_status(:bad_request)
      expect(json["error"]["code"]).to eq("invalid_filter")
    end
  end

  describe "DELETE /api/v1/teams/:team_id/memberships/:id" do
    it "prevents removing the team owner" do
      owner_membership = TeamMembership.find_by(team: team, user: owner)
      create(:team_membership, team: team, user: member, role: :admin)

      delete "/api/v1/teams/#{team.id}/memberships/#{owner_membership.id}", headers: auth_headers(member)

      expect(response).to have_http_status(:forbidden)
    end
  end
end
