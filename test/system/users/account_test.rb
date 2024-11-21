require "system/test_case"

module System::Users
  class TwoFactorTest < System::TestCase
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
    end
  end
end
