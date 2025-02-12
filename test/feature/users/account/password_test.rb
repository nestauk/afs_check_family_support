require "feature/test_case"

module Users
  module Account
    class PasswordTest < Feature::TestCase
      test "permissions" do
        sign_out
        assert_needs_auth users_account_edit_password_path
        assert_needs_auth users_account_edit_password_path, :patch
      end

      test "render edit password" do
        sign_in_as create(:user)

        get users_account_edit_password_path

        assert_response :ok
        assert_see "Change password"
        assert_see "Current password"
        assert_see "New password"
      end

      test "valid update password" do
        user = create(:user, password: "old-ravine-lexeme")
        sign_in_as user

        patch users_account_edit_password_path, params: {password_challenge: "old-ravine-lexeme", password: "ravine-lexeme"}

        assert_response :redirect
        assert_redirected_to users_account_url

        follow_redirect!
        assert_see "Your password was successfully changed"

        user.reload
        assert user.authenticate_password("ravine-lexeme")

        assert_event user, "password_changed"
      end

      test "invalid update password wrong password" do
        user = create(:user, password: "ravine-lexeme")
        sign_in_as user

        patch users_account_edit_password_path, params: {password_challenge: "wrong password", password: "password"}

        assert_response :unprocessable_entity
        assert_see "Password is invalid"
        assert_see "Password is too short \\(minimum is 10 characters\\)"
        assert_see "Password might easily be guessed"

        user.reload
        assert user.authenticate_password("ravine-lexeme")

        assert_event user, "invalid_password_challenge", for: "change_password"
      end

      test "invalid update password missing challenge" do
        user = create(:user, password: "ravine-lexeme")
        sign_in_as user

        patch users_account_edit_password_path, params: {password: "password"}

        assert_response :unprocessable_entity
        assert_see "Password can't be blank"
        assert_see "Password is too short \\(minimum is 10 characters\\)"
        assert_see "Password might easily be guessed"

        user.reload
        assert user.authenticate_password("ravine-lexeme")

        assert_event user, "invalid_password_challenge", for: "change_password"
      end
    end
  end
end
