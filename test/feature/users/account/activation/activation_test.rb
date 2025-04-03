require "feature/test_case"

module Users::Account::Activation
  module ActivationTestHelper
    def activation_url email
      signed_email = verifier.generate(["activate", email], expires_in: 1.week)

      users_account_activate_path(signed_email: signed_email)
    end
  end

  class ActivationTest < Feature::TestCase
    include ActivationTestHelper

    test "permissions" do
      sign_in_as create(:user)

      assert_needs_guest activation_url("user@example.com")
      assert_needs_guest activation_url("user@example.com"), :post
    end

    test "invalid activate user exists" do
      create(:user, email: "user@example.com")

      post activation_url("user@example.com")

      assert_response :redirect
      assert_redirected_to auth_path
      follow_redirect!
      assert_see "You have already activated your account. Please login to continue."
      assert 0, User.count
    end

    test "invalid activate expired link" do
      url = activation_url("user@example.com")
      travel 8.days

      post url

      assert_response :redirect
      assert_redirected_to auth_path
      follow_redirect!
      assert_see "That activation link has expired"
      assert 0, User.count
    end
  end
end
