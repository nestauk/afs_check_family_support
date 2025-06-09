require "system/test_case"

module System::Users
  class TwoFactorTest < System::TestCase
    class GivenWhenThen < System::TestCase
      test "view account" do
        user = create(:user, email: "user@example.com", first_name: "Bob", last_name: "Smith")

        @given.i_am_signed_in_as user
        @when.i_visit("/users/account")
        @then.i_see("Your account")
          .and.i_see("Name")
          .and.i_see("Bob Smith")
          .and.i_see("Email")
          .and.i_see("user@example.com")
          .and.i_take_snapshot("users.account")
          .and.the_page_is_accessible
      end
    end

    class VisitAssert < System::TestCase
      test "view account" do
        user = create(:user, email: "user@example.com", first_name: "Bob", last_name: "Smith")

        sign_in(user)
        visit "/users/account"
        assert_text "Your account"
        assert_text "Name"
        assert_text "Bob Smith"
        assert_text "Email"
        assert_text "user@example.com"
        take_snapshot("users.account")
        assert_page_is_accessible
      end
    end
  end
end
