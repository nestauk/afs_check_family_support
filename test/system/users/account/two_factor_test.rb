require "system/test_case"

module System::Users
  module Account
    class TwoFactorTest < System::TestCase
      test "enable 2fa" do
        @given.i_am_signed_in

        @when.i_visit("/users/account")
        @then.i_see("Enable 2FA")

        @when.i_click("Enable 2FA")
        @then.i_see("Enable two factor authentication")
          .and.i_take_snapshot("users.account.enable_2fa")
          .and.the_page_is_accessible

        otp_secret = page.find("input[x-ref='copyText']", visible: :all)["value"]

        @when.i_enter(totp_code(otp_secret), into: "Verification code")
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

        @when.i_enter("ravine-lexeme", into: "Password")
          .and.i_press("Disable 2FA")
        @then.i_see("Two factor authentication has been successfully disabled")
          .and.i_see("Enable 2FA")
      end

      private

      def totp_code otp_secret
        totp = ROTP::TOTP.new(otp_secret, issuer: "APPLICATION_NAME")

        totp.now
      end
    end
  end
end
