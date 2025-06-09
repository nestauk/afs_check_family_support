require "system/test_case"

module System::Users
  module Account
    class ActivationTest < System::TestCase
      # Delete as appropriate, depending which you prefer
      class GivenWhenThen < System::TestCase
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

      class VisitAssert < System::TestCase
        test "activate account" do
          signed_email = verifier.generate(["activate", "user@example.com"], expires_in: 1.week)

          visit "/users/account/activate/#{signed_email}"
          assert_page_is_accessible
          assert_text "You are creating an account"
          assert_text "user@example.com"
          fill_in "First name", with: "Bob"
          fill_in "Last name", with: "Ross"

          click_button "Next"

          assert_text "Create a password"
          take_snapshot("users.account.activate.password")
          fill_in "Password", with: "ravine-lexeme"

          click_button "Activate"
          assert_text "Your account has been activated! Please login to continue."
        end
      end
    end
  end
end
