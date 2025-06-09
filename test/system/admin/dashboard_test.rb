require "system/test_case"

module System::Admin
  class DashboardTest < System::TestCase
    # Delete as appropriate, depending which you prefer
    class GivenWhenThen < System::TestCase
      test "show" do
        admin = create(:user, is_admin: true)

        @given.i_am_signed_in_as admin
        @when.i_visit("/admin")
        @then.i_see("Admin dashboard")
          .and.i_see("1 user")
          .and.i_see("Manage users")
          .and.i_take_snapshot("admin.dashboard")
          .and.the_page_is_accessible
      end
    end

    class VisitAssert < System::TestCase
      test "show" do
        admin = create(:user, is_admin: true)

        sign_in(admin)
        visit admin_dashboard_path
        assert_text "Admin dashboard"
        assert_text "1 user"
        assert_text "Manage users"
        take_snapshot("admin.dashboard")
        assert_page_is_accessible
      end
    end
  end
end
