require "feature/test_case"

class HttpErrorTest < Feature::TestCase
  test "show 404" do
    get "/testing/error/404"

    assert_response :not_found
    assert_see "404 Not Found"
    assert_see "We can't seem to find the page you're looking for"
  end

  test "show 419" do
    get "/testing/error/419"

    assert_equal 419, @response.response_code
    assert_see "419 Page Expired"
    assert_see "Your session has expired"
  end

  test "show 500" do
    get "/testing/error/500"

    assert_response :internal_server_error
    assert_see "500 Internal Server Error"
    assert_see "Something went wrong"
  end
end
