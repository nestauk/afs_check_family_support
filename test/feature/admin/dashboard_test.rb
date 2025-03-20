require "feature/test_case"

module Admin
  # @see Admin::DashboardController
  class DashboardTest < Feature::TestCase
    test "permissions" do
      sign_out
      assert_needs_auth admin_dashboard_path

      sign_in_as create(:user, is_admin: false)
      assert_forbidden admin_dashboard_path
    end

    test "render" do
      sign_in_as create(:user, is_admin: true)
      create :user

      get admin_dashboard_path

      assert_response :ok
      assert_see "Admin dashboard"
      assert_see "2 users"
    end
  end
end
