module Api
  module V1
    class TeamMembershipsController < ApplicationController
      before_action :set_team
      before_action :set_membership, only: %i[update destroy]

      def index
        authorize @team.team_memberships.new, :index?, policy_class: MembershipPolicy
        return unless valid_role_filter?

        memberships = filtered_memberships.includes(:user).order(:created_at)
        render json: TeamMembershipBlueprint.render_as_hash(memberships)
      end

      def create
        return if reject_owner_role!

        membership = @team.team_memberships.new(membership_params)
        authorize membership, policy_class: MembershipPolicy
        membership.save!
        AuditLogger.record(
          team: @team, user: current_user, action: "membership.created", auditable: membership,
          metadata: { member_user_id: membership.user_id, role: membership.role }
        )
        render json: TeamMembershipBlueprint.render_as_hash(membership), status: :created
      end

      def update
        return if reject_owner_role!

        authorize @membership, policy_class: MembershipPolicy
        previous_role = @membership.role
        @membership.update!(role: membership_params[:role])
        AuditLogger.record(
          team: @team, user: current_user, action: "membership.role_changed", auditable: @membership,
          metadata: { member_user_id: @membership.user_id, from: previous_role, to: @membership.role }
        )
        render json: TeamMembershipBlueprint.render_as_hash(@membership)
      end

      def destroy
        authorize @membership, policy_class: MembershipPolicy
        AuditLogger.record(
          team: @team, user: current_user, action: "membership.removed", auditable: @membership,
          metadata: { member_user_id: @membership.user_id, role: @membership.role }
        )
        @membership.destroy!
        head :no_content
      end

      private

      def set_team
        @team = Team.find(params[:team_id])
      end

      def set_membership
        @membership = @team.team_memberships.find(params[:id])
      end

      def membership_params
        params.require(:membership).permit(:user_id, :role)
      end

      def filtered_memberships
        scope = @team.team_memberships
        scope = scope.where(role: params[:role]) if params[:role].present?
        scope
      end

      def valid_role_filter?
        return true if params[:role].blank? || TeamMembership.roles.key?(params[:role].to_s)

        render_error(
          status: :bad_request,
          code: "invalid_filter",
          message: "Invalid role filter",
          details: { role: [ "must be one of: #{TeamMembership.roles.keys.join(', ')}" ] }
        )
        false
      end

      # Ownership is assigned exactly once, automatically, when a team is created
      # (see TeamsController#create) and is not transferable through this endpoint.
      def reject_owner_role!
        return false unless membership_params[:role].to_s == "owner"

        render_error(
          status: :unprocessable_content,
          code: "validation_failed",
          message: "Validation failed",
          details: { role: [ "cannot be set to owner through this endpoint" ] }
        )
        true
      end
    end
  end
end
