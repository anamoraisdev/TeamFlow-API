module Api
  module V1
    class InvitationsController < ApplicationController
      before_action :set_team, only: %i[index create destroy]
      before_action :set_invitation, only: %i[destroy accept decline]

      def index
        authorize @team.invitations.new, :index?, policy_class: InvitationPolicy
        pagy, invitations = pagy(@team.invitations.pending.order(:created_at))
        render json: { invitations: InvitationBlueprint.render_as_hash(invitations), meta: pagination_meta(pagy) }
      end

      def create
        return if invalid_role!

        authorize @team.invitations.new, policy_class: InvitationPolicy

        invited_email = invitation_params[:invited_email].to_s.downcase
        return render_no_account_error(invited_email) unless User.exists?(email: invited_email)

        invitation = @team.invitations.new(invitation_params.merge(invited_by: current_user))
        invitation.save!
        InvitationNotifierJob.perform_later(invitation.id)
        AuditLogger.record(
          team: @team, user: current_user, action: "invitation.created", auditable: invitation,
          metadata: { invited_email: invitation.invited_email, role: invitation.role }
        )
        render json: InvitationBlueprint.render_as_hash(invitation), status: :created
      rescue ActiveRecord::RecordNotUnique
        render_conflict("a pending invitation for this email already exists on this team")
      end

      def destroy
        authorize @invitation, policy_class: InvitationPolicy
        @invitation.revoke!
        AuditLogger.record(team: @team, user: current_user, action: "invitation.revoked", auditable: @invitation)
        render json: InvitationBlueprint.render_as_hash(@invitation)
      rescue Invitation::AlreadyProcessedError => e
        render_conflict(e.message)
      end

      def mine
        pagy, invitations = pagy(
          Invitation.where(invited_email: current_user.email, status: :pending).order(:created_at)
        )
        render json: { invitations: InvitationBlueprint.render_as_hash(invitations), meta: pagination_meta(pagy) }
      end

      def accept
        authorize @invitation, policy_class: InvitationPolicy
        @invitation.accept!(current_user)
        AuditLogger.record(team: @invitation.team, user: current_user, action: "invitation.accepted", auditable: @invitation)
        render json: InvitationBlueprint.render_as_hash(@invitation)
      rescue Invitation::AlreadyProcessedError, Invitation::ExpiredError, ActiveRecord::StaleObjectError => e
        render_conflict(e.try(:message) || "invitation was already processed")
      rescue ActiveRecord::RecordNotUnique
        render_conflict("you are already a member of this team")
      end

      def decline
        authorize @invitation, policy_class: InvitationPolicy
        @invitation.decline!
        AuditLogger.record(team: @invitation.team, user: current_user, action: "invitation.declined", auditable: @invitation)
        render json: InvitationBlueprint.render_as_hash(@invitation)
      rescue Invitation::AlreadyProcessedError, ActiveRecord::StaleObjectError => e
        render_conflict(e.try(:message) || "invitation was already processed")
      end

      private

      def set_team
        @team = Team.find(params[:team_id])
      end

      def set_invitation
        @invitation = params[:team_id].present? ? @team.invitations.find(params[:id]) : Invitation.find(params[:id])
      end

      def invitation_params
        params.require(:invitation).permit(:invited_email, :role)
      end

      def invalid_role!
        role = params.dig(:invitation, :role)
        return false if role.blank? || Invitation.roles.key?(role.to_s)

        render_error(
          status: :unprocessable_content,
          code: "validation_failed",
          message: "Validation failed",
          details: { role: [ "must be one of: #{Invitation.roles.keys.join(', ')}" ] }
        )
        true
      end

      def render_no_account_error(email)
        render_error(
          status: :unprocessable_content,
          code: "validation_failed",
          message: "Validation failed",
          details: { invited_email: [ "no account exists for #{email}" ] }
        )
      end

      def render_conflict(message)
        render_error(status: :conflict, code: "conflict", message: message)
      end
    end
  end
end
