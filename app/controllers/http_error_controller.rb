class HttpErrorController < ApplicationController
  reset_all_callbacks

  def show
    set_status

    if @status == 403
      render :forbidden, status: @status
    elsif @status == 404
      render :not_found, status: @status
    elsif @exception.exception.instance_of? ActionController::InvalidAuthenticityToken
      @status = 419
      @status_text = "Page Expired"
      render :session_expired, status: @status
    else
      render :error, status: @status
    end
  end

  def set_status
    @exception = ActionDispatch::ExceptionWrapper.new(
      ActiveSupport::BacktraceCleaner.new,
      request.env["action_dispatch.exception"],
    )
    @status = @exception.status_code
    @status_text = Rack::Utils::HTTP_STATUS_CODES[@status] || "Error"
  end
end
