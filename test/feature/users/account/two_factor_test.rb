require "feature/test_case"

module Users
  module Account
    class TwoFactorTest < Feature::TestCase
      test "permissions" do
        sign_out
        assert_needs_auth users_account_enable_2fa_path
        assert_needs_auth users_account_enable_2fa_path, :patch
        assert_needs_auth users_account_disable_2fa_path
        assert_needs_auth users_account_disable_2fa_path, :patch
      end

      test "render enable 2fa" do
        sign_in_as create(:user)

        get users_account_enable_2fa_path

        assert_response :ok
        assert_see "Enable two factor authentication"
        assert_see "OTP secret"
        assert_see "Verification code"
      end

      test "valid enable 2fa" do
        user = create(:user)
        sign_in_as user

        get users_account_enable_2fa_path
        otp_secret = assert_see_html(/(?<=value=")[A-Z0-9]{32}(?=")/).to_s

        patch users_account_enable_2fa_path, params: {totp: totp_code(otp_secret)}

        assert_response :redirect
        assert_redirected_to users_account_url

        follow_redirect!
        assert_see "Two factor authentication has been successfully enabled"

        user.reload
        assert_equal otp_secret, user.otp_secret

        assert_event user, "two_factor_activated"
      end

      test "invalid enable 2fa" do
        user = create(:user)
        sign_in_as user

        patch users_account_enable_2fa_path, params: {totp: "12345"}

        assert_response :unprocessable_entity
        assert_see "That verification code didn't work. Please try again."

        user.reload
        assert_nil user.otp_secret
      end

      test "render disable 2fa" do
        user = create(:user)
        sign_in_as user
        user.update!(otp_secret: OTP_SECRET)

        get users_account_disable_2fa_path

        assert_response :ok
        assert_see "Disable two factor authentication"
        assert_see "Password"
      end

      test "valid disable 2fa" do
        user = create(:user, password: "ravine-lexeme")
        sign_in_as user
        user.update!(otp_secret: OTP_SECRET)

        patch users_account_disable_2fa_path, params: {password_challenge: "ravine-lexeme"}

        assert_response :redirect
        assert_redirected_to users_account_url

        follow_redirect!
        assert_see "Two factor authentication has been successfully disabled"

        user.reload
        assert_nil user.otp_secret

        assert_event user, "two_factor_deactivated"
      end

      test "invalid disable 2fa wrong password" do
        user = create(:user)
        sign_in_as user
        user.update!(otp_secret: OTP_SECRET)

        patch users_account_disable_2fa_path, params: {password_challenge: "wrong password"}

        assert_response :unprocessable_entity
        assert_see "Password is invalid"

        user.reload
        assert OTP_SECRET, user.otp_secret

        assert_event user, "invalid_password_challenge", for: "deactivate_2fa"
      end

      test "invalid disable 2fa missing password" do
        user = create(:user)
        sign_in_as user
        user.update!(otp_secret: OTP_SECRET)

        patch users_account_disable_2fa_path, params: {}

        assert_response :unprocessable_entity
        assert_see "Password can't be blank"

        user.reload
        assert OTP_SECRET, user.otp_secret

        assert_event user, "invalid_password_challenge", for: "deactivate_2fa"
      end

      test "redirect to disable" do
        user = create(:user)
        sign_in_as user
        user.update!(otp_secret: OTP_SECRET)

        get users_account_enable_2fa_path

        assert_response :redirect
        assert_redirected_to users_account_disable_2fa_path
      end

      test "redirect to enable" do
        user = create(:user)
        sign_in_as user

        get users_account_disable_2fa_path

        assert_response :redirect
        assert_redirected_to users_account_enable_2fa_path
      end

      private

      OTP_SECRET = "KKUFXOHZOOLJYH3XGA3NGTWSSPEQKX6D"

      def totp_code(otp_secret, time = Time.current)
        totp = ROTP::TOTP.new(otp_secret, issuer: Rails.configuration.application_name)

        totp.at time
      end
    end
  end
end
