require "system/test_case"

class ApplicationTest < System::TestCase
  test "application loads" do
    visit "/"

    assert_text "Component library"
    snapshot "homepage"
  end
end