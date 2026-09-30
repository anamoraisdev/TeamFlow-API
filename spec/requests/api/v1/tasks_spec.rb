require "rails_helper"

RSpec.describe "Api::V1::Tasks", type: :request do
  let(:team) { create(:team) }
  let(:member) { create(:user) }
  let(:project) { create(:project, team: team) }

  before { create(:team_membership, team: team, user: member, role: :member) }

  describe "GET /api/v1/projects/:project_id/tasks" do
    it "filters by status, priority and assignee" do
      matching = create(:task, project: project, status: :pending, priority: :high, assignee: member)
      create(:task, project: project, status: :done, priority: :high, assignee: member)
      create(:task, project: project, status: :pending, priority: :low, assignee: nil)

      get "/api/v1/projects/#{project.id}/tasks",
          params: { status: "pending", priority: "high", assignee_id: member.id },
          headers: auth_headers(member)

      expect(response).to have_http_status(:ok)
      expect(json["tasks"].map { |t| t["id"] }).to eq([ matching.id ])
    end

    it "returns a consistent error for an invalid status filter" do
      get "/api/v1/projects/#{project.id}/tasks", params: { status: "not_a_status" }, headers: auth_headers(member)

      expect(response).to have_http_status(:bad_request)
      expect(json["error"]["code"]).to eq("invalid_filter")
    end

    it "paginates results" do
      create_list(:task, 3, project: project)

      get "/api/v1/projects/#{project.id}/tasks", params: { page: 1 }, headers: auth_headers(member)

      expect(json["meta"]["count"]).to eq(3)
    end

    it "denies access to non-members" do
      outsider = create(:user)

      get "/api/v1/projects/#{project.id}/tasks", headers: auth_headers(outsider)

      expect(response).to have_http_status(:forbidden)
    end

    it "searches by title" do
      matching = create(:task, project: project, title: "Implement authentication")
      create(:task, project: project, title: "Write docs")

      get "/api/v1/projects/#{project.id}/tasks", params: { q: "authent" }, headers: auth_headers(member)

      expect(json["tasks"].map { |t| t["id"] }).to eq([ matching.id ])
    end

    it "sorts by the requested column and direction" do
      low = create(:task, project: project, priority: :low)
      high = create(:task, project: project, priority: :high)

      get "/api/v1/projects/#{project.id}/tasks",
          params: { sort: "priority", direction: "desc" },
          headers: auth_headers(member)

      expect(json["tasks"].map { |t| t["id"] }).to eq([ high.id, low.id ])
    end

    it "returns a consistent error for an invalid sort column" do
      get "/api/v1/projects/#{project.id}/tasks", params: { sort: "not_a_column" }, headers: auth_headers(member)

      expect(response).to have_http_status(:bad_request)
      expect(json["error"]["code"]).to eq("invalid_filter")
    end
  end

  describe "POST /api/v1/projects/:project_id/tasks" do
    it "allows any team member to create a task" do
      post "/api/v1/projects/#{project.id}/tasks",
           params: { task: { title: "New task", status: "pending", priority: "medium" } },
           headers: auth_headers(member)

      expect(response).to have_http_status(:created)
    end

    it "rejects an assignee outside the team with a standard validation error" do
      outsider = create(:user)

      post "/api/v1/projects/#{project.id}/tasks",
           params: { task: { title: "New task", status: "pending", priority: "medium", assignee_id: outsider.id } },
           headers: auth_headers(member)

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["error"]["code"]).to eq("validation_failed")
    end
  end

  describe "PATCH /api/v1/tasks/:id" do
    it "allows any team member to update a task" do
      task = create(:task, project: project)

      patch "/api/v1/tasks/#{task.id}", params: { task: { status: "done" } }, headers: auth_headers(member)

      expect(response).to have_http_status(:ok)
      expect(json["status"]).to eq("done")
    end
  end
end
