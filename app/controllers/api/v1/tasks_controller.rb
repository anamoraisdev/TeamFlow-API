module Api
  module V1
    class TasksController < ApplicationController
      before_action :set_project, only: %i[index create]
      before_action :set_task, only: %i[show update destroy]

      def index
        authorize @project.tasks.new, :index?, policy_class: TaskPolicy
        return unless valid_filters?

        pagy, tasks = pagy(filtered_tasks.order(:created_at))
        render json: { tasks: TaskBlueprint.render_as_hash(tasks), meta: pagination_meta(pagy) }
      end

      def create
        task = @project.tasks.new(task_params)
        authorize task
        task.save!
        AuditLogger.record(team: @project.team, user: current_user, action: "task.created", auditable: task)
        render json: TaskBlueprint.render_as_hash(task), status: :created
      end

      def show
        render json: TaskBlueprint.render_as_hash(@task)
      end

      def update
        @task.update!(task_params)
        AuditLogger.record(team: @task.project.team, user: current_user, action: "task.updated", auditable: @task)
        render json: TaskBlueprint.render_as_hash(@task)
      end

      def destroy
        AuditLogger.record(team: @task.project.team, user: current_user, action: "task.deleted", auditable: @task)
        @task.destroy!
        head :no_content
      end

      private

      def set_project
        @project = Project.find(params[:project_id])
      end

      def set_task
        @task = Task.find(params[:id])
        authorize @task
      end

      def task_params
        params.require(:task).permit(:title, :description, :status, :priority, :due_date, :assignee_id)
      end

      def filtered_tasks
        scope = @project.tasks
        scope = scope.where(status: params[:status]) if params[:status].present?
        scope = scope.where(priority: params[:priority]) if params[:priority].present?
        scope = scope.where(assignee_id: params[:assignee_id]) if params[:assignee_id].present?
        scope
      end

      def valid_filters?
        if params[:status].present? && !Task.statuses.key?(params[:status].to_s)
          return invalid_filter_error(:status, Task.statuses.keys)
        end

        if params[:priority].present? && !Task.priorities.key?(params[:priority].to_s)
          return invalid_filter_error(:priority, Task.priorities.keys)
        end

        true
      end

      def invalid_filter_error(field, allowed_values)
        render_error(
          status: :bad_request,
          code: "invalid_filter",
          message: "Invalid #{field} filter",
          details: { field => [ "must be one of: #{allowed_values.join(', ')}" ] }
        )
        false
      end
    end
  end
end
