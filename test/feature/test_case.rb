require "test_helper"
require "minitest/mock"

DatabaseCleaner.clean_with :truncation
DatabaseCleaner.strategy = :transaction

module Feature
  # Feature tests work at the HTTP request/response level, passing requests to the application and
  # testing responses. Feature tests should be detailed and isolated. Test one thing at once and aim
  # to test all scenarios.
  class TestCase < ActionDispatch::IntegrationTest
    def before_setup
      super

      DatabaseCleaner.start
      host! "127.0.0.1:3000"
    end

    def after_teardown
      DatabaseCleaner.clean
      Rails.cache.clear

      super
    end

    def sign_in_as(user)
      post auth_path(params: {email: user.email, password: user.password})

      assert_response :redirect, "Unable to login as #{user.inspect}"

      user
    end

    def sign_in_as_admin
      sign_in_as create(:user, is_admin: true)
    end

    def sign_out
      get signout_path

      assert_response :redirect, "Unable to sign out"
    end

    def assert_last_email_to email
      assert_equal email, ActionMailer::Base.deliveries.last.to.first
    end

    def assert_see_email subject
      assert_equal subject, ActionMailer::Base.deliveries.last.subject
    end

    def assert_see_in_email text
      last_email = ActionMailer::Base.deliveries.last
      html_body = last_email.html_part.body.to_s.gsub(/\s{2,}/, "\n").strip
      assert html_body.match(text), "Expected to see \"#{text}\" in email html body text:\n#{html_body}"

      text_body = last_email.text_part.body.to_s.gsub(/\s{2,}/, "\n").strip
      assert text_body.match(text), "Expected to see \"#{text}\" in email text body:\n#{text_body}"
    end

    def assert_see(text)
      document = ActionView::Base.full_sanitizer.sanitize(@response.body.gsub(/^.*<body>(.*)<\/body>.*$/mi, "\\1")).gsub(/\s{2,}/, "\n").strip
      match = document.match(text)
      assert document.match(text), "Expected to see \"#{text}\" in:\n#{document}"

      match
    end

    def assert_dont_see(text)
      document = ActionView::Base.full_sanitizer.sanitize(@response.body.gsub(/^.*<body>(.*)<\/body>.*$/mi, "\\1")).gsub(/\s{2,}/, "\n").strip
      assert !document.match(text), "Expected not to see \"#{text}\" in:\n#{document}"
    end

    def assert_see_html(html)
      match = @response.body.match(html)
      assert @response.body.match(html), "Expected to see \"#{html}\" in:\n#{document_root_element}"

      match
    end

    def assert_dont_see_html(html)
      assert !@response.body.match(html), "Expected not to see \"#{html}\" in:\n#{document_root_element}"
    end

    def assert_not_found path, method = :get
      process method, path

      assert_response :not_found
    end

    def assert_needs_auth path, method = :get
      process method, path

      assert_redirected_to auth_path
    end

    def assert_needs_guest path, method = :get
      process method, path

      assert_redirected_to dashboard_path
    end

    def session
      get "/testing/get_session"

      JSON.parse(@response.body).deep_symbolize_keys
    end

    def set_session(**data)
      post "/testing/set_session", params: data, as: :json
    end
  end
end
