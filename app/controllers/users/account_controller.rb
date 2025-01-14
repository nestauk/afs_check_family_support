module Users
  class AccountController < ::ApplicationController
    before_action :authenticated

    def index
    end
  end
end
