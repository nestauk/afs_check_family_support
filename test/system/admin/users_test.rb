require "system/test_case"

module System::Admin
  class UsersTest < System::TestCase
    test "index" do
      admin = create(:user, is_admin: true, first_name: "Bob", last_name: "Ross", email: "bob@example.com")
      create(:user, first_name: "Rob", last_name: "Boss", email: "rob@example.com")

      @given.i_am_signed_in_as admin
      @when.i_visit("/admin/users")
      @then.i_see("Manage users")
        .and.i_see("Bob Ross")
        .and.i_see("bob@example.com")
        .and.i_see("Rob Boss")
        .and.i_see("rob@example.com")
        .and.i_take_snapshot("admin.users.index")
        .and.the_page_is_accessible
    end

    test "invite" do
      admin = create(:user, is_admin: true)

      @given.i_am_signed_in_as admin
      @when.i_visit("/admin/users/invite")
      @then.i_see("Invite someone to #{ Rails.configuration.application_name }")

      @when.i_type("first-email@example.com", into: "[name=\"emails[]\"]", nth: 0)
        .and.i_press("Add email")
        .and.i_type("second-email@example.com", into: "[name=\"emails[]\"]", nth: 1)
      @then.i_take_snapshot("admin.users.invite")
        .and.the_page_is_accessible

      @when.i_press("Send invitations")
      @then.i_am_redirected_to("/admin/users")
        .and.i_see("Invitations were successfully sent")
        .and.i_see_emails("You have been invited to join #{ Rails.configuration.application_name }", count: 2)
    end

    test "show" do
      admin = create(:user, is_admin: true)
      user = create(:user, first_name: "Rob", last_name: "Boss", email: "rob@example.com")

      @given.i_am_signed_in_as admin
      @when.i_visit("/admin/users/#{user.id}")
      @then.i_see("Rob Boss")
        .and.i_see("rob@example.com")
        .and.i_see("Change email")
        .and.i_see("Grant admin access")
        .and.i_see("Send password reset")
        .and.i_take_snapshot("admin.users.show")
        .and.the_page_is_accessible
    end

    test "change email" do
      admin = create(:user, is_admin: true)
      user = create(:user, first_name: "Rob", last_name: "Boss", email: "rob@example.com")

      @given.i_am_signed_in_as admin
      @when.i_visit("/admin/users/#{user.id}")
        .and.i_click("Change email")
      @then.i_see("You are changing the email address for Rob Boss.")
        .and.i_see("Their current email address is rob@example.com.")

      @when.i_type("robert@example.com", into: "Email")
        .and.i_press("Change email")
      @then.i_am_redirected_to("/admin/users/#{user.id}")
        .and.i_see("A confirmation email was sent to robert@example.com")
    end

    test "toggle admin access" do
      admin = create(:user, is_admin: true)
      user = create(:user, first_name: "Rob", last_name: "Boss", email: "rob@example.com")

      @given.i_am_signed_in_as admin
      @when.i_visit("/admin/users/#{user.id}")
        .and.i_press("Grant admin access")
      @then.i_see("Admin status was successfully granted")
        .and.i_see("Revoke admin access")

      @when.i_press("Revoke admin access")
      @then.i_see("Admin status was successfully revoked")
        .and.i_see("Grant admin access")
    end

    test "send password reset" do
      admin = create(:user, is_admin: true)
      user = create(:user, first_name: "Rob", last_name: "Boss", email: "rob@example.com")

      @given.i_am_signed_in_as admin
      @when.i_visit("/admin/users/#{user.id}")
        .and.i_press("Send password reset")
      @then.i_see("A password reset link was sent to rob@example.com")
    end

    test "disable 2fa" do
      admin = create(:user, is_admin: true)
      user = create(:user, first_name: "Rob", last_name: "Boss", email: "rob@example.com", otp_secret: "a")

      @given.i_am_signed_in_as admin
      @when.i_visit("/admin/users/#{user.id}")
        .and.i_press("Disable 2FA")
      @then.i_see("Two factor authentication was successfully disabled")
    end
  end
end
