require "feature/test_case"

class ComponentLibraryTest < Feature::TestCase
  test "show component library" do
    get "/component-library"

    assert_response :ok
    assert_see "Component library"
  end
end
