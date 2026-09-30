require "rails_helper"

RSpec.describe "Api::V1::AuditLogs", type: :request do
  let(:team) { create(:team) }
  let(:owner) { create(:user) }
  let(:member) { create(:user) }

  before do
    create(:team_membership, team: team, user: owner, role: :owner)
    create(:team_membership, team: team, user: member, role: :member)
  end

  describe "GET /api/v1/teams/:team_id/audit_logs" do
    it "records an entry when a project is created and lets the owner read it" do
      post "/api/v1/teams/#{team.id}/projects", params: { project: { name: "New Project" } }, headers: auth_headers(owner)

      get "/api/v1/teams/#{team.id}/audit_logs", headers: auth_headers(owner)

      expect(response).to have_http_status(:ok)
      actions = json["audit_logs"].map { |entry| entry["action"] }
      expect(actions).to include("project.created")
    end

    it "forbids a plain member from reading the audit log" do
      get "/api/v1/teams/#{team.id}/audit_logs", headers: auth_headers(member)

      expect(response).to have_http_status(:forbidden)
    end

    it "filters by event" do
      create(:audit_log, team: team, user: owner, action: "team.updated")
      create(:audit_log, team: team, user: owner, action: "project.created")

      get "/api/v1/teams/#{team.id}/audit_logs", params: { event: "team.updated" }, headers: auth_headers(owner)

      expect(response).to have_http_status(:ok)
      expect(json["audit_logs"].map { |entry| entry["action"] }).to eq([ "team.updated" ])
    end
  end
end
