require "feature/test_case"

class ComponentLibraryTest < Feature::TestCase
  test "component library" do
    get "/component-library"

    assert_response :ok
  end
end
