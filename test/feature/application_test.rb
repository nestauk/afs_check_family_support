require "feature/test_case"

class ApplicationTest < Feature::TestCase
  test "application loads" do
    get "/"

    assert_response :ok
  end
end