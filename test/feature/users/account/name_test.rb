require "feature/test_case"

module Users
  module Account
    class NameTest < Feature::TestCase
      test "permissions" do
        sign_out
        assert_needs_auth users_account_edit_name_path
        assert_needs_auth users_account_edit_name_path, :patch
      end

      test "render edit name" do
        sign_in_as create(:user)

        get users_account_edit_name_path

        assert_response :ok
        assert_see "Change name"
        assert_see "First name"
        assert_see "Last name"
      end

      test "valid update name" do
        user = create(:user, first_name: "William", last_name: "Williamson")
        sign_in_as user

        patch users_account_edit_name_path, params: {first_name: "Bill ", last_name: "Billson"}

        assert_response :redirect
        assert_redirected_to users_account_url

        follow_redirect!
        assert_see "Your name was successfully changed"

        user.reload
        assert_equal "Bill", user.first_name
        assert_equal "Billson", user.last_name
      end

      test "invalid update name" do
        user = create(:user, first_name: "William", last_name: "Williamson")
        sign_in_as user

        patch users_account_edit_name_path, params: {first_name: "", last_name: ""}

        assert_response :unprocessable_entity
        assert_see "First name can't be blank"
        assert_see "Last name can't be blank"

        user.reload
        assert_equal "William", user.first_name
        assert_equal "Williamson", user.last_name
      end
    end
  end
end
