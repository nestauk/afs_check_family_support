require "system/test_case"

module System::Users
  class AuthenticationTest < System::TestCase
    test "sign in" do
      create(:user, email: "user@example.com", password: "ravine-lexeme")

      @when.i_visit("/auth")
      @then.i_see("Sign in")
        .and.i_take_snapshot("users.auth")

      @when.i_enter("user@example.com", into: "Email")
        .and.i_enter("ravine-lexeme", into: "Password")
        .and.i_press("Sign in")
      @then.i_see("Signed in successfully")
    end
  end
end
