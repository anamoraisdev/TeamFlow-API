class ApplicationController < ActionController::API
  before_action :authenticate_request

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_validation_error
  rescue_from ActionController::ParameterMissing, with: :render_bad_request

  private

  def authenticate_request
    header = request.headers["Authorization"]
    token = header&.split(" ")&.last
    decoded = token && JsonWebToken.decode(token)
    @current_user = decoded && User.find_by(id: decoded[:user_id])

    render_unauthorized unless @current_user
  end

  def current_user
    @current_user
  end

  def render_error(status:, code:, message:, details: nil)
    body = { error: { code: code, message: message } }
    body[:error][:details] = details if details.present?
    render json: body, status: status
  end

  def render_unauthorized
    render_error(status: :unauthorized, code: "unauthorized", message: "Invalid or missing authentication token")
  end

  def render_not_found(exception)
    render_error(status: :not_found, code: "not_found", message: exception.message)
  end

  def render_validation_error(exception)
    render_error(
      status: :unprocessable_content,
      code: "validation_failed",
      message: "Validation failed",
      details: exception.record.errors.to_hash(true)
    )
  end

  def render_bad_request(exception)
    render_error(status: :bad_request, code: "bad_request", message: exception.message)
  end
end
