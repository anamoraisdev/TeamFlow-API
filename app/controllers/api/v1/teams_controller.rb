module Api
  module V1
    class TeamsController < ApplicationController
      before_action :set_team, only: %i[show update destroy]

      def index
        pagy, teams = pagy(policy_scope(Team).order(:created_at))
        render json: { teams: TeamBlueprint.render_as_hash(teams), meta: pagination_meta(pagy) }
      end

      def create
        team = Team.new(team_params)
        authorize team

        ActiveRecord::Base.transaction do
          team.save!
          team.team_memberships.create!(user: current_user, role: :owner)
        end

        render json: TeamBlueprint.render_as_hash(team), status: :created
      end

      def show
        render json: TeamBlueprint.render_as_hash(@team)
      end

      def update
        @team.update!(team_params)
        AuditLogger.record(team: @team, user: current_user, action: "team.updated", auditable: @team)
        render json: TeamBlueprint.render_as_hash(@team)
      end

      def destroy
        AuditLogger.record(team: @team, user: current_user, action: "team.deleted", auditable: @team)
        @team.destroy!
        head :no_content
      end

      private

      def set_team
        @team = Team.find(params[:id])
        authorize @team
      end

      def team_params
        params.require(:team).permit(:name)
      end
    end
  end
end
