module Api
  module V1
    class ProjectsController < ApplicationController
      before_action :set_team, only: %i[index create]
      before_action :set_project, only: %i[show update destroy]

      def index
        authorize @team.projects.new, :index?, policy_class: ProjectPolicy
        pagy, projects = pagy(searched_projects.order(:created_at))
        render json: { projects: ProjectBlueprint.render_as_hash(projects), meta: pagination_meta(pagy) }
      end

      def create
        project = @team.projects.new(project_params)
        authorize project
        project.save!
        AuditLogger.record(team: @team, user: current_user, action: "project.created", auditable: project)
        render json: ProjectBlueprint.render_as_hash(project), status: :created
      end

      def show
        render json: ProjectBlueprint.render_as_hash(@project)
      end

      def update
        @project.update!(project_params)
        AuditLogger.record(team: @project.team, user: current_user, action: "project.updated", auditable: @project)
        render json: ProjectBlueprint.render_as_hash(@project)
      end

      def destroy
        AuditLogger.record(team: @project.team, user: current_user, action: "project.deleted", auditable: @project)
        @project.destroy!
        head :no_content
      end

      private

      def set_team
        @team = Team.find(params[:team_id])
      end

      def set_project
        @project = Project.find(params[:id])
        authorize @project
      end

      def project_params
        params.require(:project).permit(:name, :description)
      end

      def searched_projects
        scope = @team.projects
        scope = scope.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
        scope
      end
    end
  end
end
