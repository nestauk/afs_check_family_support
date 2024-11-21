require "feature/test_case"

module Users
  class AuthenticationTest < Feature::TestCase
    test "permissions" do
      sign_in_as create(:user)
      assert_needs_guest auth_path
      assert_needs_guest auth_path, :post
    end

    test "render sign in" do
      get auth_path

      assert_response :ok
      assert_see "Sign in"
      assert_see "Email"
      assert_see "Password"
    end

    test "valid sign in" do
      user = create(:user, email: "user@example.com", password: "permit-lexeme")

      post auth_path, params: {email: " USER@example.com ", password: "permit-lexeme"}

      assert_response :redirect
      assert_redirected_to dashboard_url

      assert_event user, "successful_password_challenge", for: "sign_in"
    end

    def invalid_sign_in(params)
      user = create(:user, email: "user@example.com", password: "permit-lexeme")

      post auth_path, params: params

      assert_response :unprocessable_entity
      assert_see "Those details do not match. Please try again."

      # Events are only created for valid users
      if params[:email] == "user@example.com"
        assert_event user, "invalid_password_challenge", for: "sign_in"
      end
    end
    test "invalid sign in with no email" do
      invalid_sign_in password: "permit-lexeme"
    end
    test "invalid sign in with no password" do
      invalid_sign_in email: "user@example.com"
    end
    test "invalid sign in with wrong email" do
      invalid_sign_in email: "invalid-user@example.com", password: "permit-lexeme"
    end
    test "invalid sign in with wrong password" do
      invalid_sign_in email: "user@example.com", password: "pass-word"
    end
    test "invalid sign in with spaces around password" do
      invalid_sign_in email: "user@example.com", password: " permit-lexeme "
    end

    test "authenticated user redirected to dashboard on get" do
      sign_in_as create(:user)

      get auth_path

      assert_response :redirect
      assert_redirected_to dashboard_url
    end

    test "authenticated user redirected to dashboard on post" do
      sign_in_as create(:user)

      post auth_path

      assert_response :redirect
      assert_redirected_to dashboard_url
    end

    test "authentication is rate limited" do
      user = create :user, email: "user@example.com"

      # Perform 5 invalid requests
      5.times do
        post auth_path, params: {email: "user@example.com", password: "wrong-password"}
        assert_response :unprocessable_entity
        assert_see "Those details do not match. Please try again."
      end

      # User email "user@example.com" is rate limited for 5 minutes
      post auth_path, params: {email: "user@example.com", password: "wrong-password"}
      assert_response :unprocessable_entity
      assert_see "Too many attempts. Please try again later."

      # Non-user email "other_user@example.com" is not rate limited
      post auth_path, params: {email: "other_user@example.com", password: "wrong-password"}
      assert_response :unprocessable_entity
      assert_see "Those details do not match. Please try again."

      travel 6.minutes

      # Email is no longer limited, perform 5 invalid requests
      5.times do
        post auth_path, params: {email: "user@example.com", password: "wrong-password"}
        assert_response :unprocessable_entity
        assert_see "Those details do not match. Please try again."
      end

      # User email "user@example.com" is rate limited for a further 15 minutes (including the original 5 minutes)
      post auth_path, params: {email: "user@example.com", password: "wrong-password"}
      assert_response :unprocessable_entity
      assert_see "Too many attempts. Please try again later."

      travel 10.minutes

      # User email "user@example.com" is still rate limited
      post auth_path, params: {email: "user@example.com", password: "wrong-password"}
      assert_response :unprocessable_entity
      assert_see "Too many attempts. Please try again later."

      # Events are only created for valid users
      assert_event user, "rate_limited", for: "sign_in"
    end

    test "authentication rate limit is reset on success" do
      create :user, email: "user@example.com", password: "ravine-lexeme"

      # Perform 4 invalid requests
      4.times do
        post auth_path, params: {email: "user@example.com", password: "wrong-password"}
        assert_response :unprocessable_entity
        assert_see "Those details do not match. Please try again."
      end

      # Perform 1 successful request
      post auth_path, params: {email: "user@example.com", password: "ravine-lexeme"}
      assert_response :redirect

      get signout_path

      # Perform 5 more invalid requests within original rate limit period
      5.times do
        post auth_path, params: {email: "user@example.com", password: "wrong-password"}
        assert_response :unprocessable_entity
        assert_see "Those details do not match. Please try again."
      end
    end
  end
end
