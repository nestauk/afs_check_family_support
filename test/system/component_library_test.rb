require "system/test_case"

class System::ComponentLibraryTest < System::TestCase
  test "show" do
    @when.i_visit("/component-library")
    @then.i_see("APPLICATION_NAME")
      .and.i_take_snapshot("component-library")
      .and.the_page_is_accessible
  end
end
