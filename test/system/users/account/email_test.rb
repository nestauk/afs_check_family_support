require "system/test_case"

module System::Users
  module Account
    class EmailTest < System::TestCase
      class GivenWhenThen < System::TestCase
        test "change email" do
          user = create(:user, password: "ravine-lexeme", email: "old_email@example.com")

          @given.i_am_signed_in_as user
          @when.i_visit("/users/account/edit_email")
          @then.i_see("Change email")
            .and.i_take_snapshot("users.account.edit_email")
            .and.the_page_is_accessible

          @when.i_type("new_email@example.com", into: "Email")
            .and.i_press("Change email")
          @then.i_see("A confirmation email was sent to new_email@example.com")
            .and.i_see_email("Confirm your new #{Rails.configuration.application_name} email address")

          @when.i_click_in_email("Confirm new email")
          @then.i_see("Confirm your new email address")
            .and.i_see("new_email@example.com")

          @when.i_type("ravine-lexeme", into: "Password")
            .and.i_press("Confirm new email")
          @then.i_see("Your email address has been updated successfully")
            .and.i_see("new_email@example.com")
        end
      end

      class VisitAssert < System::TestCase
        test "change email" do
          user = create(:user, password: "ravine-lexeme", email: "old_email@example.com")

          sign_in(user)
          visit "/users/account/edit_email"
          assert_page_is_accessible

          click_button "Change email"
          fill_in "Email", with: "new_email@example.com"

          click_button "Change email"
          assert_text "A confirmation email was sent to new_email@example.com"
          assert_email "new_email@example.com", "Confirm your new #{Rails.configuration.application_name} email address"

          click_email_link "Confirm new email"
          assert_text "Confirm your new email address"
          assert_text "new_email@example.com"

          fill_in "Password", with: "ravine-lexeme"
          click_button "Confirm new email"
          assert_text "Your email address has been updated successfully"
          assert_text "new_email@example.com"
        end
      end
    end
  end
end
