require "feature/test_case"

module Users
  class PasswordResetTest < Feature::TestCase
    test "permissions" do
      sign_in_as create(:user)
      assert_needs_guest users_forgot_password_path
      assert_needs_guest users_forgot_password_path, :post
      assert_needs_guest users_password_reset_path({sid: "a"})
      assert_needs_guest users_password_reset_path({sid: "a"}), :patch
    end

    test "render forgot password" do
      get users_forgot_password_path

      assert_response :ok
      assert_see "Forgot your password?"
      assert_see "Email"
    end

    test "valid forgot password" do
      user = create :user, email: "user@example.com"

      assert_emails 1 do
        post users_forgot_password_path, params: {email: " USER@example.com "}
      end

      assert_response :ok
      assert_see "Thank you"
      assert_see "If your email address matches an account, you will receive an email."

      assert_see_email "Reset your #{ Rails.configuration.application_name } password"
      assert_see_in_email users_password_reset_path(sid: "")

      assert_event user, "password_reset_request"
    end

    test "invalid forgot password" do
      assert_emails 0 do
        post users_forgot_password_path, params: {email: "invalid-user@example.com"}
      end

      assert_response :ok
      assert_see "Thank you"
      assert_see "If your email address matches an account, you will receive an email."
    end

    test "render password reset" do
      user = create :user

      get password_reset_path(user)

      assert_response :ok
      assert_see "Reset password"
      assert_see "New password"
    end

    test "expired password reset" do
      user = create :user
      path = password_reset_path(user)
      travel 21.minutes

      get path

      assert_response :redirect
      assert_redirected_to users_forgot_password_url

      follow_redirect!
      assert_see "That password reset link is invalid"
    end

    test "valid password reset" do
      user = create :user

      patch password_reset_path(user), params: {password: "dotted-buffoon"}

      assert_response :redirect
      assert_redirected_to auth_url

      follow_redirect!

      assert_see "Your password was reset successfully. Please sign in."

      user.reload
      assert user.authenticate_password("dotted-buffoon")

      assert_event user, "password_reset"
    end

    test "invalid password reset" do
      user = create :user
      password_digest = user.password_digest

      patch password_reset_path(user), params: {}

      assert_response :unprocessable_entity
      assert_see "Password is too short"

      # Ensure password is unchanged
      user.reload
      assert_equal password_digest, user.password_digest
    end

    test "password reset is rate limited" do
      create :user, email: "user@example.com"

      assert_emails 1 do
        post users_forgot_password_path, params: {email: "user@example.com"}
        assert_response :ok
      end

      assert_emails 0 do
        post users_forgot_password_path, params: {email: "user@example.com"}
        assert_response :unprocessable_entity
        assert_see "Too many attempts. Please try again later."
      end

      travel 2.minutes
      assert_emails 1 do
        post users_forgot_password_path, params: {email: "user@example.com"}
        assert_response :ok
      end
    end

    private

    def password_reset_path(user)
      users_password_reset_path sid: user.generate_token_for(:password_reset)
    end
  end
end
