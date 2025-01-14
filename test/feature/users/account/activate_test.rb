require "feature/test_case"

module Users
  module Account
    class ActivateTest < Feature::TestCase
      private

      def activation_url email
        signed_email = verifier.generate(["activate", email], expires_in: 1.week)

        users_account_activate_path(signed_email: signed_email)
      end

      public

      test "permissions" do
        sign_in_as create(:user)

        assert_needs_guest activation_url("user@example.com")
        assert_needs_guest activation_url("user@example.com"), :post
      end

      test "render activate" do
        get activation_url("user@example.com")

        assert_response :ok
        assert_see "First name"
        assert_see "Last name"
        assert_see "Email"
        assert_see_html "user@example.com"
        assert_see "Password"
      end

      test "valid activate" do
        post activation_url("user@example.com"), params: {first_name: "Bob", last_name: "Ross", password: "ravine-lexeme"}

        assert_response :redirect
        assert_redirected_to auth_path
        follow_redirect!
        assert_see "Your account has been activated! Please login to continue."

        user = User.first!
        assert_equal "Bob", user.first_name
        assert_equal "Ross", user.last_name
        assert user.authenticate_password "ravine-lexeme"
      end

      test "invalid activate user exists" do
        create(:user, email: "user@example.com")

        post activation_url("user@example.com"), params: {first_name: "Bob", last_name: "Ross", password: "ravine-lexeme"}

        assert_response :redirect
        assert_redirected_to auth_path
        follow_redirect!
        assert_see "You have already activated your account. Please login to continue."
        assert 0, User.count
      end

      test "invalid activate expired link" do
        url = activation_url("user@example.com")
        travel 8.days

        post url, params: {first_name: "Bob", last_name: "Ross", password: "ravine-lexeme"}

        assert_response :redirect
        assert_redirected_to auth_path
        follow_redirect!
        assert_see "That activation link has expired"
        assert 0, User.count
      end

      test "activate validates" do
        post activation_url("user@example.com")

        assert_response :unprocessable_entity
        assert_see "First name can't be blank"
        assert_see "Last name can't be blank"
        assert_see "Password can't be blank"
        assert 0, User.count
      end
    end
  end
end
