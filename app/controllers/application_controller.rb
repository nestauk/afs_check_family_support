class ApplicationController < ActionController::Base
  before_action :set_current_request_details
  before_action :authenticate_user
  rate_limit to: 500, within: 1.minute

  add_flash_types :success, :error

  private

  def abort_not_found
    raise ActionController::RoutingError.new("Not Found")
  end

  def require_authenticated
    if Current.user.nil?
      redirect_to main_app.auth_url
    end
  end

  def require_admin
    if Current.user.nil?
      return redirect_to main_app.auth_url
    end

    unless Current.user.is_admin?
      abort_not_found
    end
  end

  def require_unauthenticated
    if session[:user_id].present?
      redirect_to main_app.dashboard_url
    end
  end

  def set_current_request_details
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
    Current.errors = {}
  end

  def authenticate_user
    return if session[:user_id].nil?

    user = User.find_by(id: session[:user_id])

    if user.nil?
      session.delete :user_id

      return
    end

    Current.user = user
  end

  def authenticate_user_and_require_admin
    authenticate_user
    require_admin
  end

  def verifier
    ActiveSupport::MessageVerifier.new(Rails.configuration.secret_key_base)
  end

  def clear_rate_limit keys
    cache_store.delete_multi(Array.wrap(keys).map { |key| "rate-limit:#{controller_path}:#{key}" })
  end
end
