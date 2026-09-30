require "rails_helper"

RSpec.describe "Api::V1::Invitations", type: :request do
  include ActiveJob::TestHelper

  let(:team) { create(:team) }
  let(:owner) { create(:user) }
  let(:member) { create(:user) }

  before { create(:team_membership, team: team, user: owner, role: :owner) }

  describe "POST /api/v1/teams/:team_id/invitations" do
    it "allows an owner to invite an existing user and enqueues a notification job" do
      invitee = create(:user)

      expect {
        post "/api/v1/teams/#{team.id}/invitations",
             params: { invitation: { invited_email: invitee.email, role: "member" } },
             headers: auth_headers(owner)
      }.to have_enqueued_job(InvitationNotifierJob)

      expect(response).to have_http_status(:created)
      expect(json["status"]).to eq("pending")
    end

    it "forbids a plain member from inviting others" do
      create(:team_membership, team: team, user: member, role: :member)
      invitee = create(:user)

      post "/api/v1/teams/#{team.id}/invitations",
           params: { invitation: { invited_email: invitee.email } },
           headers: auth_headers(member)

      expect(response).to have_http_status(:forbidden)
    end

    it "rejects inviting an email with no registered account" do
      post "/api/v1/teams/#{team.id}/invitations",
           params: { invitation: { invited_email: "nobody@example.com" } },
           headers: auth_headers(owner)

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["error"]["details"]).to have_key("invited_email")
    end

    it "rejects setting role to owner through this endpoint" do
      invitee = create(:user)

      post "/api/v1/teams/#{team.id}/invitations",
           params: { invitation: { invited_email: invitee.email, role: "owner" } },
           headers: auth_headers(owner)

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["error"]["details"]).to have_key("role")
    end

    it "returns a conflict when a pending invitation for that email already exists" do
      invitee = create(:user)
      create(:invitation, team: team, invited_email: invitee.email, invited_by: owner)

      post "/api/v1/teams/#{team.id}/invitations",
           params: { invitation: { invited_email: invitee.email } },
           headers: auth_headers(owner)

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["error"]["code"]).to eq("validation_failed")
    end
  end

  describe "GET /api/v1/teams/:team_id/invitations" do
    it "lists pending invitations for admins/owners only" do
      create(:invitation, team: team, invited_by: owner)
      create(:team_membership, team: team, user: member, role: :member)

      get "/api/v1/teams/#{team.id}/invitations", headers: auth_headers(owner)
      expect(response).to have_http_status(:ok)
      expect(json["invitations"].size).to eq(1)

      get "/api/v1/teams/#{team.id}/invitations", headers: auth_headers(member)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /api/v1/teams/:team_id/invitations/:id" do
    it "allows an owner to revoke a pending invitation" do
      invitation = create(:invitation, team: team, invited_by: owner)

      delete "/api/v1/teams/#{team.id}/invitations/#{invitation.id}", headers: auth_headers(owner)

      expect(response).to have_http_status(:ok)
      expect(invitation.reload).to be_revoked
    end
  end

  describe "GET /api/v1/invitations (mine)" do
    it "returns pending invitations addressed to the current user's email" do
      invitee = create(:user)
      create(:invitation, team: team, invited_email: invitee.email, invited_by: owner)
      create(:invitation, team: team, invited_by: owner)

      get "/api/v1/invitations", headers: auth_headers(invitee)

      expect(response).to have_http_status(:ok)
      expect(json["invitations"].size).to eq(1)
      expect(json["invitations"].first["invited_email"]).to eq(invitee.email)
    end
  end

  describe "POST /api/v1/invitations/:id/accept" do
    it "creates a membership and marks the invitation accepted" do
      invitee = create(:user)
      invitation = create(:invitation, team: team, invited_email: invitee.email, invited_by: owner, role: :admin)

      post "/api/v1/invitations/#{invitation.id}/accept", headers: auth_headers(invitee)

      expect(response).to have_http_status(:ok)
      expect(invitee.role_in(team)).to eq("admin")
    end

    it "forbids accepting an invitation addressed to someone else" do
      invitation = create(:invitation, team: team, invited_by: owner)

      post "/api/v1/invitations/#{invitation.id}/accept", headers: auth_headers(member)

      expect(response).to have_http_status(:forbidden)
    end

    it "returns a conflict when the invitation was already processed" do
      invitee = create(:user)
      invitation = create(:invitation, team: team, invited_email: invitee.email, invited_by: owner)
      invitation.decline!

      post "/api/v1/invitations/#{invitation.id}/accept", headers: auth_headers(invitee)

      expect(response).to have_http_status(:conflict)
    end
  end

  describe "POST /api/v1/invitations/:id/decline" do
    it "marks the invitation declined" do
      invitee = create(:user)
      invitation = create(:invitation, team: team, invited_email: invitee.email, invited_by: owner)

      post "/api/v1/invitations/#{invitation.id}/decline", headers: auth_headers(invitee)

      expect(response).to have_http_status(:ok)
      expect(invitation.reload).to be_declined
    end
  end
end
