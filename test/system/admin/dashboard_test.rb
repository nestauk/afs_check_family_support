require "system/test_case"

module System::Admin
  class DashboardTest < System::TestCase
    test "show" do
      admin = create(:user, is_admin: true)

      @given.i_am_signed_in_as admin
      @when.i_visit("/admin")
      @then.i_see("Admin dashboard")
        .and.i_see("1 user")
        .and.i_see("Manage users")
        .and.i_take_snapshot("admin.dashboard")
    end
  end
end
