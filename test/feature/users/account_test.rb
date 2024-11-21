require "feature/test_case"

module Users
  class AccountTest < Feature::TestCase
    test "permissions" do
      sign_out
      assert_needs_auth users_account_path
    end

    test "render account" do
      sign_in_as create(:user, first_name: "Bob", last_name: "Ross", email: "user@example.com")

      get users_account_path

      assert_response :ok
      assert_see "Bob Ross"
      assert_see "Change name"
      assert_see "user@example.com"
      assert_see "Change email"
      assert_see "Change password"
      assert_see "Enable 2FA"
    end
  end
end
