require "feature/test_case"

module Users
  class TwoFactorTest < Feature::TestCase
    test "permissions" do
      sign_in_as create(:user)
      assert_needs_guest challenge_2fa_url
      assert_needs_guest challenge_2fa_url, :post
    end

    def setup
      super

      @user = create(:user, email: "user@example.com", password: "permit-lexeme", otp_secret: OTP_SECRET)
      post auth_path, params: {email: "user@example.com", password: "permit-lexeme"}
    end

    test "redirected to otp challenge" do
      # Setup will send a post request to auth_path

      assert_response :redirect
      assert_redirected_to challenge_2fa_url

      follow_redirect!

      assert_response :ok
      assert_see "Two factor"
      assert_see "Verification code"

      event = Event.where(action: "totp_challenge").first!
      assert_equal @user, event.user
    end

    def valid_totp(totp)
      post challenge_2fa_path, params: {totp: totp}

      assert_response :redirect
      assert_redirected_to dashboard_url

      assert_event @user, "successful_totp_challenge"
    end
    test "valid otp" do
      valid_totp totp_code
    end
    test "valid otp with spaces" do
      valid_totp " #{totp_code} "
    end

    def invalid_totp params
      post challenge_2fa_path, params: params

      assert_response :unprocessable_entity
      assert_see "That verification code didn't work. Please try again."

      assert_event @user, "invalid_totp_challenge"
    end
    test "invalid otp with missing totp" do
      invalid_totp({})
    end
    test "invalid otp with empty totp" do
      invalid_totp({topt: ""})
    end
    test "invalid otp with old totp" do
      invalid_totp({topt: totp_code(2.minutes.ago)})
    end

    test "otp challenge is rate limited" do
      # Perform 3 invalid requests
      3.times do
        post challenge_2fa_path, params: {totp: "00000"}
        assert_response :unprocessable_entity
        assert_see "That verification code didn't work. Please try again."
      end

      # The fourth attempt is rate limited
      post challenge_2fa_path, params: {totp: "00000"}

      assert_response :redirect
      assert_redirected_to auth_url
      follow_redirect!
      assert_see "Too many attempts. Please try again later."

      # The rate limit has expired after 75 seconds
      travel 76.seconds

      post auth_path, params: {email: "user@example.com", password: "permit-lexeme"}
      post challenge_2fa_path, params: {totp: "00000"}

      assert_response :unprocessable_entity
      assert_see "That verification code didn't work. Please try again."
    end

    private

    OTP_SECRET = "KKUFXOHZOOLJYH3XGA3NGTWSSPEQKX6D"

    def totp_code(time = Time.current)
      totp = ROTP::TOTP.new(OTP_SECRET, issuer: "APPLICATION_NAME")

      totp.at time
    end
  end
end
