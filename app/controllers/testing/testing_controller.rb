module Testing
  class TestingController < ApplicationController
    reset_all_callbacks

    before_action :ensure_test

    def set_session
      session.merge! params.to_unsafe_h.except(:controller, :testing, :action)

      head :ok
    end

    def get_session
      render json: session, content_type: "application/json"
    end

    def http_error
      request.env["action_dispatch.exception"] = case params[:status]
      when "400"
        ActionController::BadRequest.new("Bad Request")
      when "403"
        HttpError::Forbidden.new
      when "404"
        HttpError::NotFound.new
      when "419"
        ActionController::InvalidAuthenticityToken.new("Page Expired")
      else
        # 500 Internal Server Error
        StandardError.new
      end

      HttpErrorController.dispatch(:show, request, response)
    end

    private

    def ensure_test
      unless Rails.env.test?
        raise HttpError::NotFound
      end
    end
  end
end
