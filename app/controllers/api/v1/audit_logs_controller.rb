module Api
  module V1
    class AuditLogsController < ApplicationController
      before_action :set_team

      def index
        authorize @team, :index?, policy_class: AuditLogPolicy
        return unless valid_filters?

        pagy, audit_logs = pagy(filtered_audit_logs.order(created_at: :desc))
        render json: { audit_logs: AuditLogBlueprint.render_as_hash(audit_logs), meta: pagination_meta(pagy) }
      end

      private

      def set_team
        @team = Team.find(params[:team_id])
      end

      def filtered_audit_logs
        scope = @team.audit_logs
        # Filter param is "event", not "action" — :action is a reserved
        # routing key (it's always the controller action name in `params`),
        # so a query param literally named "action" would be shadowed.
        scope = scope.where(action: params[:event]) if params[:event].present?
        scope = scope.where(user_id: params[:user_id]) if params[:user_id].present?
        scope
      end

      def valid_filters?
        return true if params[:user_id].blank? || params[:user_id].to_s.match?(/\A\d+\z/)

        render_error(
          status: :bad_request,
          code: "invalid_filter",
          message: "Invalid user_id filter",
          details: { user_id: [ "must be an integer" ] }
        )
        false
      end
    end
  end
end
