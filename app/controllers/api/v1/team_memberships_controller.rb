module Api
  module V1
    class TeamMembershipsController < ApplicationController
      before_action :set_team
      before_action :set_membership, only: %i[update destroy]

      def index
        authorize @team.team_memberships.new, :index?, policy_class: MembershipPolicy
        memberships = @team.team_memberships.includes(:user).order(:created_at)
        render json: TeamMembershipBlueprint.render_as_hash(memberships)
      end

      def create
        membership = @team.team_memberships.new(membership_params)
        authorize membership, policy_class: MembershipPolicy
        membership.save!
        render json: TeamMembershipBlueprint.render_as_hash(membership), status: :created
      end

      def update
        authorize @membership, policy_class: MembershipPolicy
        @membership.update!(role: membership_params[:role])
        render json: TeamMembershipBlueprint.render_as_hash(@membership)
      end

      def destroy
        authorize @membership, policy_class: MembershipPolicy
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
    end
  end
end
