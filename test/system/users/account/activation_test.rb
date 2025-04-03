require "system/test_case"

module System::Users
  module Account
    class ActivationTest < System::TestCase
      test "activate account" do
        signed_email = verifier.generate(["activate", "user@example.com"], expires_in: 1.week)

        @when.i_visit("/users/account/activate/#{signed_email}")
        @then.i_see("You are creating an account")
          .and.i_see("user@example.com")
          .and.i_see("First name")
          .and.i_see("Last name")
          .and.i_take_snapshot("users.account.activate.name")
          .and.the_page_is_accessible

        @when.i_type("Bob", into: "first_name")
          .and.i_type("Ross", into: "last_name")
          .and.i_press("Next")
        @then.i_see("Create a password")
          .and.i_take_snapshot("users.account.activate.password")

        @when.i_type("ravine-lexeme", into: "password")
          .and.i_press("Activate")
        @then.i_see("Your account has been activated! Please login to continue.")
      end
    end
  end
end
