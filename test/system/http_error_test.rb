require "system/test_case"

class System::HttpErrorTest < System::TestCase
  test "errors" do
    @when.i_visit("/testing/error/403", expected_status: 403)
    @then.i_see("403 Forbidden")
      .and.i_see("You don't have access")
      .and.i_take_snapshot("http-error.403")
      .and.the_page_is_accessible

    @when.i_visit("/testing/error/404", expected_status: 404)
    @then.i_see("404 Not Found")
      .and.i_see("We can't seem to find the page you're looking for")
      .and.i_take_snapshot("http-error.404")
      .and.the_page_is_accessible

    @when.i_visit("/testing/error/419", expected_status: 419)
    @then.i_see("419 Page Expired")
      .and.i_see("Your session has expired")
      .and.i_take_snapshot("http-error.419")
      .and.the_page_is_accessible

    @when.i_visit("/testing/error/500", expected_status: 500)
    @then.i_see("500 Internal Server Error")
      .and.i_see("Something went wrong")
      .and.i_take_snapshot("http-error.500")
      .and.the_page_is_accessible
  end
end
