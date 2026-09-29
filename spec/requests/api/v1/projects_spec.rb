require "rails_helper"

RSpec.describe "Api::V1::Projects", type: :request do
  let(:team) { create(:team) }
  let(:member) { create(:user) }
  let(:admin) { create(:user) }

  before do
    create(:team_membership, team: team, user: member, role: :member)
    create(:team_membership, team: team, user: admin, role: :admin)
  end

  describe "POST /api/v1/teams/:team_id/projects" do
    it "forbids a plain member from creating a project" do
      post "/api/v1/teams/#{team.id}/projects", params: { project: { name: "New Project" } }, headers: auth_headers(member)

      expect(response).to have_http_status(:forbidden)
    end

    it "allows an admin to create a project" do
      post "/api/v1/teams/#{team.id}/projects", params: { project: { name: "New Project" } }, headers: auth_headers(admin)

      expect(response).to have_http_status(:created)
      expect(json["name"]).to eq("New Project")
    end
  end

  describe "GET /api/v1/projects/:id" do
    it "allows any team member to view a project" do
      project = create(:project, team: team)

      get "/api/v1/projects/#{project.id}", headers: auth_headers(member)

      expect(response).to have_http_status(:ok)
    end
  end
end
