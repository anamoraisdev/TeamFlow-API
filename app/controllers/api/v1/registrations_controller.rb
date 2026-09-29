module Api
  module V1
    class RegistrationsController < ApplicationController
      skip_before_action :authenticate_request

      def create
        user = User.new(registration_params)

        if user.save
          token = JsonWebToken.encode({ user_id: user.id })
          render json: { token: token, user: UserBlueprint.render_as_hash(user) }, status: :created
        else
          render_error(
            status: :unprocessable_content,
            code: "validation_failed",
            message: "Validation failed",
            details: user.errors.to_hash(true)
          )
        end
      end

      private

      def registration_params
        params.require(:user).permit(:name, :email, :password)
      end
    end
  end
end
