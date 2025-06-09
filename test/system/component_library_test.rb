require "system/test_case"

class System::ComponentLibraryTest < System::TestCase
  class GivenWhenThen < System::TestCase
    test "show" do
      @when.i_visit("/component-library")
      @then.i_see("Component library")
        .and.i_take_snapshot("component-library")
    end
  end

  class VisitAssert < System::TestCase
    test "show" do
      visit "/component-library"
      assert_text "Component library"
      take_snapshot("component-library")
    end
  end
end
