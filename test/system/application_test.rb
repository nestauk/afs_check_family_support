require_relative "test_case"

class ApplicationTest < System::TestCase
  test "application loads" do
    visit "/"

    assert_text "Hello world"
    snapshot "homepage"
  end
end