require "test_helper"
require "rails/test_help"

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
    end

    def after_teardown
      DatabaseCleaner.clean
      super
    end
  end
end