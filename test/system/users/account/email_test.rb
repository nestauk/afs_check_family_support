require "system/test_case"

module System::Users
  module Account
    class EmailTest < System::TestCase
      test "change email" do
        user = create(:user, password: "ravine-lexeme", email: "old_email@example.com")

        @given.i_am_signed_in_as user
        @when.i_visit("/users/account/edit_email")
        @then.i_see("Change email")
          .and.i_take_snapshot("users.account.edit_email")

        @when.i_enter("new_email@example.com", into: "Email")
          .and.i_press("Change email")
        @then.i_see("A confirmation email was sent to new_email@example.com")
          .and.i_see_email("Confirm your new APPLICATION_NAME email address")

        @when.i_click_in_email("Confirm new email")
        @then.i_see("Confirm your new email address")
          .and.i_see("new_email@example.com")

        @when.i_enter("ravine-lexeme", into: "Password")
          .and.i_press("Confirm new email")
        @then.i_see("Your email address has been updated successfully")
          .and.i_see("new_email@example.com")
      end
    end
  end
end
