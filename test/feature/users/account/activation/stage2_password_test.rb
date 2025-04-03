require "feature/test_case"
require "helpers/multistage_form_helpers"
require_relative "activation_test"

module Users::Account::Activation
  class Stage2PasswordTest < Feature::TestCase
    include ActivationTestHelper
    include MultistageFormHelpers
    controller ActivationController

    STAGE_DATA = {
      _stage: Stage2Password,
      first_name: "Bob",
      last_name: "Ross",
    }

    def setup
      set_form_data(**STAGE_DATA)
    end

    test "render" do
      get activation_url("user@example.com")

      assert_response :ok
      assert_see "Create a password"
      assert_see "Back"
      assert_see "Activate"
    end

    test "back action" do
      post activation_url("user@example.com"), params: {action: "back"}

      assert_response :redirect
      follow_redirect!

      assert_see "user@example.com"
      assert_see "First name"
      assert_see_html 'value="Bob"'
      assert_see "Last name"
      assert_see_html 'value="Ross"'

      assert_stage(Stage1Name)
      assert_equal "Bob", form_data[:first_name]
      assert_equal "Ross", form_data[:last_name]
      assert_nil form_data[:password]
    end

    test "submit action" do
      post activation_url("user@example.com"), params: {action: "submit", password: "ravine-lexeme"}

      assert_response :redirect
      assert_redirected_to auth_path
      follow_redirect!
      assert_see "Your account has been activated! Please login to continue."

      user = User.first!
      assert_equal "Bob", user.first_name
      assert_equal "Ross", user.last_name
      assert user.authenticate_password "ravine-lexeme"

      assert_nil form_data
    end

    test "submit action validates" do
      post activation_url("user@example.com"), params: {action: "submit", password: "password"}

      assert_see "Password is too short"
      assert_see "Password might easily be guessed"
    end
  end
end
