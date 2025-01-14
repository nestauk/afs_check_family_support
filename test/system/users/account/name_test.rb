require "system/test_case"

module System::Users
  module Account
    class NameTest < System::TestCase
      test "change name" do
        user = create(:user, first_name: "Bob", last_name: "Smith")

        @given.i_am_signed_in_as user
        @when.i_visit("/users/account/edit_name")
        @then.i_see("Change name")
          .and.i_take_snapshot("users.account.edit_name")
          .and.the_page_is_accessible

        @when.i_enter("Robert", into: "First name")
          .and.i_enter("Smythe", into: "Last name")
          .and.i_press("Change name")
        @then.i_see("Your name was successfully changed")
          .and.i_see("Robert Smythe")
      end
    end
  end
end
