require "system/test_case"

module System::Users
  class PasswordResetTest < System::TestCase
    class GivenWhenThen < System::TestCase
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
          .and.i_see_email("Reset your #{Rails.configuration.application_name} password")

        @when.i_click_in_email("Reset password")
        @then.i_see("Reset password")
          .and.i_take_snapshot("users.forgot_password | set_password")
          .and.the_page_is_accessible

        @when.i_type("ravine-lexeme", into: "New password")
          .and.i_press("Set password")
        @then.i_see("Your password was reset successfully. Please sign in.")
      end
    end

    class VisitAssert < System::TestCase
      test "reset password" do
        create(:user, email: "user@example.com")

        visit "users/forgot_password"
        assert_text "Forgot your password?"
        take_snapshot("users.forgot_password")
        assert_page_is_accessible

        fill_in "Email", with: "user@example.com"
        click_button "Reset password"
        assert_text "Thank you"
        take_snapshot("users.forgot_password | email_sent")
        assert_page_is_accessible
        assert_email "user@example.com", "Reset your #{Rails.configuration.application_name} password"

        click_email_link("Reset password")
        assert_text "Reset password"
        take_snapshot("users.forgot_password | set_password")
        assert_page_is_accessible

        fill_in "New password", with: "ravine-lexeme"
        click_button "Set password"
        assert_text "Your password was reset successfully. Please sign in."
      end
    end
  end
end
