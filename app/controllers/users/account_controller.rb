module Users
  class AccountController < ::ApplicationController
    before_action :require_authenticated

    def index
    end
  end
end
