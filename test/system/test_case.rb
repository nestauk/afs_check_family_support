require "test_helper"
require "capybara/cuprite"
require "database_cleaner/core"
require "helpers/given"
require "helpers/then"
require "helpers/when"

DatabaseCleaner.clean_with :truncation
DatabaseCleaner.strategy = :transaction

module System
  # System tests use the Cuprite browser to simulate a user clicking and inputting data into the
  # site. System tests are slow and hard to maintain, so we only write the highest value tests.
  class TestCase < ActionDispatch::SystemTestCase
    Capybara.default_max_wait_time = 15
    Capybara.disable_animation = true
    Capybara.javascript_driver = :cuprite
    driven_by(
      :cuprite,
      options: {
        window_size: [1200, 800],
        headless: true,
        browser_options: {
          "no-sandbox": nil
        }
      }
    )

    def setup
      super

      @name = "#{self.class.name.delete_prefix("System::").delete_suffix("Test").underscore}_#{name}"

      DatabaseCleaner.start
      @given = Given.new self
      @when = When.new self
      @then = Then.new self
    end

    def teardown
      super

      DatabaseCleaner.clean
      Rails.cache.clear
      ActionMailer::Base.deliveries.clear
    end

    private

    # Overwrite the default failure screenshot file name to be more useful
    def image_name
      @name
    end
  end
end
