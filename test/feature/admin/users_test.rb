require "feature/test_case"

module Admin
  # @see Admin::UsersController
  class UsersTest < Feature::TestCase
    test "permissions" do
      user = create(:user)
      sign_out
      assert_needs_auth admin_users_path
      assert_needs_auth admin_users_invite_path(user)
      assert_needs_auth admin_users_invite_path(user), :post
      assert_needs_auth admin_user_path(user)
      assert_needs_auth admin_user_change_email_path(user)
      assert_needs_auth admin_user_change_email_path(user), :post
      assert_needs_auth admin_user_enable_admin_path(user), :post
      assert_needs_auth admin_user_disable_admin_path(user), :post
      assert_needs_auth admin_user_password_reset_path(user), :post
      assert_needs_auth admin_user_disable_2fa_path(user), :post

      sign_in_as create(:user, is_admin: false)
      assert_not_found admin_users_path
      assert_not_found admin_users_invite_path(user)
      assert_not_found admin_users_invite_path(user), :post
      assert_not_found admin_user_path(user)
      assert_not_found admin_user_change_email_path(user)
      assert_not_found admin_user_change_email_path(user), :post
      assert_not_found admin_user_enable_admin_path(user), :post
      assert_not_found admin_user_disable_admin_path(user), :post
      assert_not_found admin_user_password_reset_path(user), :post
      assert_not_found admin_user_disable_2fa_path(user), :post
    end

    test "render index" do
      sign_in_as create(:user, is_admin: true, first_name: "Bob", last_name: "Ross", email: "bob@example.com")
      create :user, first_name: "Rob", last_name: "Boss", email: "rob@example.com"

      get admin_users_path

      assert_response :ok
      assert_see "Users"
      assert_see "Bob Ross"
      assert_see "Admin"
      assert_see "bob@example.com"
      assert_see "Rob Boss"
      assert_see "Admin"
      assert_see "rob@example.com"
    end

    test "index is paginated" do
      sign_in_as create(:user, is_admin: true, first_name: "Bob", last_name: "Ross", email: "bob@example.com")
      9.times { create :user, first_name: "Bob", last_name: "Ross" }
      create :user, first_name: "Rob", last_name: "Boss"

      get admin_users_path

      assert_response :ok
      assert_see "Bob Ross"
      assert_dont_see "Rob Boss"

      get "#{admin_users_path}?page=2"
      assert_response :ok
      assert_dont_see "Bob Ross"
      assert_see "Rob Boss"
    end

    test "render invite" do
      sign_in_as create(:user, is_admin: true, first_name: "Bob", last_name: "Ross", email: "bob@example.com")

      get admin_users_invite_path

      assert_response :ok
      assert_see "Invite someone to #{Rails.configuration.application_name}"
      assert_see "Emails"
      assert_see_html "Send invitation"
    end

    test "invite user" do
      admin = sign_in_as create(:user, is_admin: true)

      assert_emails 1 do
        post admin_users_invite_path, params: {emails: ["new-user@example.com"]}
      end

      assert_response :redirect
      assert_redirected_to admin_users_path
      follow_redirect!
      assert_see "Invitations were successfully sent"

      assert_see_email "You have been invited to join #{Rails.configuration.application_name}"
      assert_last_email_to "new-user@example.com"
      assert_see_in_email users_account_activate_path(signed_email: "")

      assert_event admin, "admin_users_invite_sent", to: "new-user@example.com"
    end

    test "invite multiple users" do
      admin = sign_in_as create(:user, is_admin: true)

      assert_emails 3 do
        post admin_users_invite_path, params: {emails: [
          "new-user@example.com",
          "new-user2@example.com",
          "new-user3@example.com",
          # Blank entries should be removed
          " ",
          # Duplicate entries should be ignored
          "new-user@example.com"
        ]}
      end

      assert_response :redirect
      assert_redirected_to admin_users_path
      follow_redirect!
      assert_see "Invitations were successfully sent"

      assert_equal 3, admin.events.where(action: "admin_users_invite_sent").count
    end

    def validate_invite(emails, errors)
      admin = sign_in_as create(:user, is_admin: true, email: "user@example.com")

      assert_emails 0 do
        post admin_users_invite_path, params: {emails: emails}
      end

      assert_response :unprocessable_entity
      errors.each do |error|
        assert_see error
      end

      assert_equal 0, admin.events.where(action: "admin_users_invite_sent").count
    end
    test "invite fails with no emails" do
      validate_invite [], ["Please enter at least one email address"]
    end
    test "invite fails with blank emails" do
      validate_invite ["", " "], ["Please enter at least one email address"]
    end
    test "invite fails with not emails" do
      validate_invite ["abc"], ["Please enter a valid email address"]
    end
    test "invite fails for existing user" do
      validate_invite ["user@example.com", "new-user@example.com"], ["That user already exists"]
    end
    test "invite does not send invitation if any are invalid" do
      validate_invite ["new-user@example.com", "abc"], []
    end

    test "render show" do
      sign_in_as_admin
      user = create :user, first_name: "Rob", last_name: "Boss", email: "rob@example.com", otp_secret: "secret"

      get admin_user_path user

      assert_response :ok
      assert_see "Rob Boss"
      assert_see "rob@example.com"
      assert_see "Grant admin access"
      assert_see "Disable 2FA"
    end

    test "render change_email" do
      sign_in_as_admin
      user = create :user, first_name: "Rob", last_name: "Boss", email: "rob@example.com"

      get admin_user_change_email_path user

      assert_response :ok
      assert_see "Change email"
      assert_see "Rob Boss"
      assert_see "rob@example.com"
      assert_see "Email"
    end

    test "change email" do
      admin = sign_in_as_admin
      user = create :user, email: "user@example.com"

      assert_emails 1 do
        post admin_user_change_email_path user, email: "new@example.com"
      end

      assert_response :redirect
      assert_redirected_to admin_user_path user
      follow_redirect!
      assert_see "A confirmation email was sent to new@example.com"
      assert_see_email "Confirm your new #{Rails.configuration.application_name} email address"

      assert_event admin, "admin_user_email_change_request", for: user.id
      assert_event user, "email_change_request", to: "new@example.com", by: admin.id
    end

    test "enable admin" do
      admin = sign_in_as_admin
      user = create :user, is_admin: false

      post admin_user_enable_admin_path user

      assert_response :redirect
      assert_redirected_to admin_user_path user
      follow_redirect!
      assert_see "Admin status was successfully granted"

      user.reload
      assert user.is_admin?

      assert_event admin, "admin_user_admin_enabled", for: user.id
      assert_event user, "admin_enabled", by: admin.id
    end

    test "disable admin" do
      admin = sign_in_as_admin
      user = create :user, is_admin: true

      post admin_user_disable_admin_path user

      assert_response :redirect
      assert_redirected_to admin_user_path user
      follow_redirect!
      assert_see "Admin status was successfully revoked"

      user.reload
      assert !user.is_admin?

      assert_event admin, "admin_user_admin_disabled", for: user.id
      assert_event user, "admin_disabled", by: admin.id
    end

    test "send password reset" do
      admin = sign_in_as_admin
      user = create :user, email: "user@example.com"

      assert_emails 1 do
        post admin_user_password_reset_path user
      end

      assert_response :redirect
      assert_redirected_to admin_user_path user
      follow_redirect!
      assert_see "A password reset link was sent to user@example.com"
      assert_see_email "Reset your #{Rails.configuration.application_name} password"

      assert_event admin, "admin_user_password_reset_request", for: user.id
      assert_event user, "password_reset_request", by: admin.id
    end

    test "disable 2fa" do
      admin = sign_in_as_admin
      user = create :user, otp_secret: "secret"

      post admin_user_disable_2fa_path user

      assert_response :redirect
      assert_redirected_to admin_user_path user
      follow_redirect!
      assert_see "Two factor authentication was successfully disabled"

      user.reload
      assert_nil user.otp_secret

      assert_event admin, "admin_user_two_factor_deactivated", for: user.id
      assert_event user, "two_factor_deactivated", by: admin.id
    end
  end
end
