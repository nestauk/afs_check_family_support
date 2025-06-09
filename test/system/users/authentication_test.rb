require "system/test_case"

module System::Users
  class AuthenticationTest < System::TestCase
    class GivenWhenThen < System::TestCase
      test "sign in" do
        create(:user, email: "user@example.com", password: "ravine-lexeme")

        @when.i_visit("/auth")
        @then.i_see("Sign in")
          .and.i_take_snapshot("users.auth")
          .and.the_page_is_accessible

        @when.i_type("user@example.com", into: "Email")
          .and.i_type("ravine-lexeme", into: "Password")
          .and.i_press("Sign in")
        @then.i_see("Signed in successfully")
      end
    end

    class VisitAssert < System::TestCase
      test "sign in" do
        create(:user, email: "user@example.com", password: "ravine-lexeme")

        visit auth_path
        assert_text "Sign in"
        take_snapshot("users.auth")
        assert_page_is_accessible

        fill_in "Email", with: "user@example.com"
        fill_in "Password", with: "ravine-lexeme"
        click_button "Sign in"
        assert_text "Signed in successfully"
      end
    end
  end
end
