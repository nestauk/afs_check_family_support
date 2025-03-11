require "feature/test_case"

class DashboardTest < Feature::TestCase
  test "show dashboard" do
    sign_in_as create(:user)

    get dashboard_path

    assert_response :ok
    assert_see "Hello, world!"
  end
end
