require "system/test_case"

module System::Users
  module Account
    class TwoFactorTest < System::TestCase
      class GivenWhenThen < System::TestCase
        test "enable 2fa" do
          @given.i_am_signed_in_as create(:user, email: "user@example.com")

          @when.i_visit("/users/account")
          @then.i_see("Enable 2FA")

          # Ensure our secret is consistent to prevent visual regression diffs
          ROTP::Base32.stub :random, "YA3A3OQ63CTS6MUC3PQHD2WKFCWRR7WJ" do
            @when.i_click("Enable 2FA")
            @then.i_see("Enable two factor authentication")
              .and.i_take_snapshot("users.account.enable_2fa")
              .and.the_page_is_accessible
          end

          otp_secret = page.find("input[x-ref='copyText']", visible: :all)["value"]

          @when.i_type(totp_code(otp_secret), into: "Verification code")
            .and.i_press("Enable 2FA")
          @then.i_see("Two factor authentication has been successfully enabled")
            .and.i_see("Disable 2FA")
        end

        test "disable 2fa" do
          user = create :user, password: "ravine-lexeme"

          @given.i_am_signed_in_as(user)
          # Enable 2FA after login to simplify the test
          user.update! otp_secret: "12345"

          @when.i_visit("/users/account")
          @then.i_see("Disable 2FA")

          @when.i_click("Disable 2FA")
          @then.i_see("Disable two factor authentication")
            .and.i_take_snapshot("users.account.disable_2fa")
            .and.the_page_is_accessible

          @when.i_type("ravine-lexeme", into: "Password")
            .and.i_press("Disable 2FA")
          @then.i_see("Two factor authentication has been successfully disabled")
            .and.i_see("Enable 2FA")
        end

        private

        def totp_code otp_secret
          totp = ROTP::TOTP.new(otp_secret, issuer: Rails.configuration.application_name)

          totp.now
        end
      end

      class VisitAssert < System::TestCase
        test "enable 2fa" do
          sign_in create(:user, email: "user@example.com")

          visit "/users/account"
          assert_text "Your account"
          assert_text "Enable 2FA"

          # Ensure our secret is consistent to prevent visual regression diffs
          ROTP::Base32.stub :random, "YA3A3OQ63CTS6MUC3PQHD2WKFCWRR7WJ" do
            click_link "Enable 2FA"
            assert_text "Enable two factor authentication"
            take_snapshot("users.account.enable_2fa")
            assert_page_is_accessible
          end

          otp_secret = page.find("input[x-ref='copyText']", visible: :all)["value"]

          fill_in "Verification code", with: totp_code(otp_secret)
          click_button "Enable 2FA"
          assert_text "Two factor authentication has been successfully enabled"
          assert_text "Disable 2FA"
        end

        test "disable 2fa" do
          user = create :user, password: "ravine-lexeme"

          sign_in user
          # Enable 2FA after login to simplify the test
          user.update! otp_secret: "12345"

          visit "/users/account"
          assert_text "Your account"
          assert_text "Disable 2FA"

          click_link "Disable 2FA"
          assert_text "Disable two factor authentication"
          take_snapshot("users.account.disable_2fa")
          assert_page_is_accessible

          fill_in "Password", with: "ravine-lexeme"
          click_button "Disable 2FA"
          assert_text "Two factor authentication has been successfully disabled"
          assert_text "Enable 2FA"
        end

        private

        def totp_code otp_secret
          totp = ROTP::TOTP.new(otp_secret, issuer: Rails.configuration.application_name)

          totp.now
        end
      end
    end
  end
end
