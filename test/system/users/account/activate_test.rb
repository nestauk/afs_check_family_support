require "system/test_case"

module System::Users
  module Account
    class ActivateTest < System::TestCase
      test "change email" do
        signed_email = verifier.generate(["activate", "user@example.com"], expires_in: 1.week)

        @when.i_visit("/users/account/activate/#{signed_email}")
        @then.i_see("Activate your account")
          .and.i_see("First name")
          .and.i_see("Last name")
          .and.i_see("Password")
          .and.i_take_snapshot("users.account.activate")

        @when.i_type("Bob", into: "first_name")
          .and.i_type("Ross", into: "last_name")
          .and.i_type("ravine-lexeme", into: "password")
          .and.i_press("Activate your account")
        @then.i_see("Your account has been activated! Please login to continue.")
      end
    end
  end
end
