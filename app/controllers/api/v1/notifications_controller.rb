module Api
  module V1
    class NotificationsController < ApplicationController
      before_action :set_notification, only: %i[read]

      def index
        scope = current_user.notifications.order(created_at: :desc)
        scope = scope.unread if params[:unread].present?
        pagy, notifications = pagy(scope)
        render json: { notifications: NotificationBlueprint.render_as_hash(notifications), meta: pagination_meta(pagy) }
      end

      def read
        authorize @notification, :update?, policy_class: NotificationPolicy
        @notification.mark_read!
        render json: NotificationBlueprint.render_as_hash(@notification)
      end

      def read_all
        current_user.notifications.unread.update_all(read_at: Time.current)
        head :no_content
      end

      private

      def set_notification
        @notification = Notification.find(params[:id])
      end
    end
  end
end
