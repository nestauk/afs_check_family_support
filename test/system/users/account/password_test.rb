require "system/test_case"

module System::Users
  module Account
    class PasswordTest < System::TestCase
      class GivenWhenThen < System::TestCase
        test "change password" do
          user = create(:user, password: "ravine-lexeme")

          @given.i_am_signed_in_as user
          @when.i_visit("/users/account/edit_password")
          @then.i_see("Change password")
            .and.i_take_snapshot("users.account.edit_password")
            .and.the_page_is_accessible

          @when.i_type("ravine-lexeme", into: "Current password")
            .and.i_type("new-ravine-lexeme", into: "New password")
            .and.i_press("Change password")
          @then.i_see("Your password was successfully changed")
        end
      end

      class VisitAssertions < System::TestCase
        test "change password" do
          user = create(:user, password: "ravine-lexeme")

          sign_in(user)
          visit "/users/account/edit_password"
          assert_text "Change password"
          take_snapshot("users.account.edit_password")
          assert_page_is_accessible

          fill_in "Current password", with: "ravine-lexeme"
          fill_in "New password", with: "new-ravine-lexeme"
          click_button "Change password"
          assert_text "Your password was successfully changed"
        end
      end
    end
  end
end
