class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }
  before_action :authenticate_user!
  before_action :configure_sanitized_params, if: :devise_controller?

  def configure_sanitized_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
  end
end
