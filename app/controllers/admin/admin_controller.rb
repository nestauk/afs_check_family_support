module Admin
  class AdminController < ::ApplicationController
    before_action :require_admin
  end
end
