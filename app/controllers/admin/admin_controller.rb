module Admin
  class AdminController < ::ApplicationController
    before_action :authenticated
    before_action :authenticate_admin

    private

    def authenticate_admin
      unless Current.user.is_admin?
        abort_not_found
      end
    end
  end
end
