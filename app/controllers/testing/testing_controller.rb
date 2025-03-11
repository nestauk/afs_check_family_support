module Testing
  class TestingController < ApplicationController
    # Disable all callbacks for this request
    __callbacks.keys.each { reset_callbacks _1 }

    before_action :ensure_test

    def set_session
      session.merge! params.to_unsafe_h.except(:controller, :testing, :action)

      head :ok
    end

    def get_session
      render json: session, content_type: "application/json"
    end

    private

    def ensure_test
      unless Rails.env.test?
        abort_not_found
      end
    end
  end
end
