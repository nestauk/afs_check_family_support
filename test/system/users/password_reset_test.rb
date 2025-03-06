require "system/test_case"

module System::Users
  class PasswordResetTest < System::TestCase
    test "reset password" do
      create(:user, email: "user@example.com")

      @when.i_visit("/users/forgot_password")
      @then.i_see("Forgot your password?")
        .and.i_take_snapshot("users.forgot_password")
        .and.the_page_is_accessible

      @when.i_type("user@example.com", into: "Email")
        .and.i_press("Reset password")
      @then.i_see("Thank you")
        .and.i_take_snapshot("users.forgot_password | email_sent")
        .and.the_page_is_accessible
        .and.i_see_email("Reset your APPLICATION_NAME password")

      @when.i_click_in_email("Reset password")
      @then.i_see("Reset password")
        .and.i_take_snapshot("users.forgot_password | set_password")
        .and.the_page_is_accessible

      @when.i_type("ravine-lexeme", into: "New password")
        .and.i_press("Set password")
      @then.i_see("Your password was reset successfully. Please sign in.")
    end
  end
end
