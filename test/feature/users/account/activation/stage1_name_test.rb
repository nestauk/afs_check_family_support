require "feature/test_case"
require "helpers/multistage_form_helpers"
require_relative "activation_test"

module Users::Account::Activation
  class Stage1NameTest < Feature::TestCase
    include ActivationTestHelper
    include MultistageFormHelpers
    controller ActivationController

    test "render" do
      get activation_url("user@example.com")

      assert_response :ok
      assert_see "user@example.com"
      assert_see "First name"
      assert_see "Last name"
      assert_see "Next"

      assert_nil(form_data)
    end

    test "next action" do
      post activation_url("user@example.com"), params: {action: "next", first_name: "Bob", last_name: "Ross"}

      assert_response :redirect
      follow_redirect!
      assert_see "Create a password"
      assert_see "Activate"

      assert_equal 0, User.count
    end

    test "next action validates" do
      post activation_url("user@example.com"), params: {action: "next"}

      assert_see "First name can't be blank"
      assert_see "Last name can't be blank"
    end
  end
end
