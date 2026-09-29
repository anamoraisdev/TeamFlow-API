module Api
  module V1
    class SessionsController < ApplicationController
      skip_before_action :authenticate_request

      def create
        user = User.find_by(email: session_params[:email]&.downcase)

        if user&.authenticate(session_params[:password])
          token = JsonWebToken.encode({ user_id: user.id })
          render json: { token: token, user: UserBlueprint.render_as_hash(user) }, status: :ok
        else
          render_error(status: :unauthorized, code: "invalid_credentials", message: "Invalid email or password")
        end
      end

      private

      def session_params
        params.require(:session).permit(:email, :password)
      end
    end
  end
end
