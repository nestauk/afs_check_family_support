require "feature/test_case"

module Users
  module Account
    class EmailTest < Feature::TestCase
      test "permissions" do
        sign_out
        assert_needs_auth users_account_edit_email_path
        assert_needs_auth users_account_edit_email_path, :post
        assert_needs_auth users_account_confirm_email_path(signed_email: "a")
        assert_needs_auth users_account_confirm_email_path(signed_email: "a"), :patch
      end

      test "render edit email" do
        sign_in_as create(:user, email: "user@example.com")

        get users_account_edit_email_path

        assert_response :ok
        assert_see "Change email"
        assert_see "user@example.com"
        assert_see "Email"
      end

      test "valid request email change" do
        user = create :user
        sign_in_as user

        assert_emails 1 do
          post users_account_edit_email_path, params: {email: "new_email@example.com"}
        end

        assert_response :redirect
        assert_redirected_to users_account_url

        follow_redirect!
        assert_see "A confirmation email was sent to new_email@example.com"

        assert_see_email "Confirm your new #{Rails.configuration.application_name} email address"
        assert_last_email_to "new_email@example.com"
        assert_see_in_email users_account_confirm_email_path(signed_email: "")

        assert_event user, "email_change_request", to: "new_email@example.com"
      end

      test "invalid request email change with same email" do
        sign_in_as create(:user, email: "user@example.com")

        assert_emails 0 do
          post users_account_edit_email_path, params: {email: "user@example.com"}
        end

        assert_response :unprocessable_entity
        assert_see "That email is already associated with your account"
      end

      test "invalid request email change with invalid email" do
        sign_in_as create(:user)

        assert_emails 0 do
          post users_account_edit_email_path, params: {email: "user email"}
        end

        assert_response :unprocessable_entity
        assert_see "Email is invalid"
      end

      test "render confirm email" do
        user = create(:user)
        sign_in_as user

        get users_account_confirm_email_path(signed_email: confirm_email_token(user, "newemail@example.com"))

        assert_response :ok
        assert_see "Confirm your new email address"
        assert_see "You are changing your account email address to newemail@example.com"
        assert_see "Password"
      end

      test "expired confirm email" do
        user = create(:user)
        sign_in_as user
        signed_email = confirm_email_token(user, "newemail@example.com")
        travel(1.day + 1.minute)

        get users_account_confirm_email_path(signed_email:)

        assert_response :redirect
        assert_redirected_to users_account_url

        follow_redirect!
        assert_see "That link has expired"
      end

      test "valid confirm email" do
        user = create(:user, email: "user@example.com", password: "ravine-lexeme")
        sign_in_as user

        assert_emails 1 do
          patch users_account_confirm_email_path(signed_email: confirm_email_token(user, "newemail@example.com")),
            params: {password_challenge: "ravine-lexeme"}
        end

        assert_response :redirect
        assert_redirected_to users_account_url

        follow_redirect!
        assert_see "Your email address has been updated successfully"

        user.reload
        assert_equal "newemail@example.com", user.email

        assert_see_email "Your #{Rails.configuration.application_name} email address has changed"
        assert_last_email_to "user@example.com"
        assert_see_in_email "newemail@example.com"

        assert_event user, "email_changed", from: "user@example.com"
      end

      test "invalid confirm email wrong password" do
        user = create(:user, email: "user@example.com")
        sign_in_as user

        patch users_account_confirm_email_path(signed_email: confirm_email_token(user, "newemail@example.com")),
          params: {password_challenge: "wrong password"}

        assert_response :unprocessable_entity
        assert_see "Password is invalid"

        user.reload
        assert_equal "user@example.com", user.email

        assert_event user, "invalid_password_challenge", for: "change_email"
      end

      test "invalid confirm email missing challenge" do
        user = create(:user, email: "user@example.com")
        sign_in_as user

        patch users_account_confirm_email_path(signed_email: confirm_email_token(user, "newemail@example.com")),
          params: {}

        assert_response :unprocessable_entity
        assert_see "Password can't be blank"

        user.reload
        assert_equal "user@example.com", user.email

        assert_event user, "invalid_password_challenge", for: "change_email"
      end

      private

      def confirm_email_token user, email
        verifier.generate([user.id, user.email, email], expires_in: 1.day)
      end
    end
  end
end
