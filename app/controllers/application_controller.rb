class ApplicationController < ActionController::Base
  before_action :set_current_request_details
  rate_limit to: 500, within: 1.minute

  add_flash_types :success, :error

  private

  def abort_not_found
    raise ActionController::RoutingError.new("Not Found")
  end

  def authenticated
    if session[:user_id].nil?
      return redirect_to auth_url
    end

    user = User.find_by(id: session[:user_id])
    if !user.nil?
      Current.user = user
    else
      redirect_to auth_url
    end
  end

  def unauthenticated
    if session[:user_id].present?
      redirect_to dashboard_url
    end
  end

  def set_current_request_details
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
    Current.errors = {}
  end

  def verifier
    ActiveSupport::MessageVerifier.new(Rails.configuration.secret_key_base)
  end

  def clear_rate_limit keys
    cache_store.delete_multi(Array.wrap(keys).map { |key| "rate-limit:#{controller_path}:#{key}" })
  end
end
