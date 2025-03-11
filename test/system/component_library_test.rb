require "system/test_case"

class System::ComponentLibraryTest < System::TestCase
  test "show" do
    @when.i_visit("/component-library")
    @then.i_see(Rails.configuration.application_name)
      .and.i_take_snapshot("component-library")
  end
end
