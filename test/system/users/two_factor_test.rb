require "system/test_case"

module System::Users
  class TwoFactorTest < System::TestCase
    test "sign in with 2fa" do
      create(:user, email: "user@example.com", password: "ravine-lexeme", otp_secret: OTP_SECRET)

      @when.i_visit("/auth")
      @then.i_see("Sign in")

      @when.i_type("user@example.com", into: "Email")
        .and.i_type("ravine-lexeme", into: "Password")
        .and.i_press("Sign in")
      @then.i_see("Two factor")
        .and.i_take_snapshot("users.auth.challenge_2fa")
        .and.the_page_is_accessible

      @when.i_type(totp_code, into: "Verification code")
        .and.i_press("Sign in")
      @then.i_see("Signed in successfully")
    end

    private

    OTP_SECRET = "KKUFXOHZOOLJYH3XGA3NGTWSSPEQKX6D"

    def totp_code
      totp = ROTP::TOTP.new(OTP_SECRET, issuer: Rails.configuration.application_name)

      totp.now
    end
  end
end
