require_relative "../../config/environment"
require "rails/test_help"
require "database_cleaner/core"

DatabaseCleaner.clean_with :truncation
DatabaseCleaner.strategy = :transaction

module System
  # System tests use a selenium browser to simulate a user clicking and inputting data into the
  # site. System tests are slow and hard to maintain, so we only write the highest value tests.
  class TestCase < ActionDispatch::SystemTestCase
    driven_by(
      :selenium,
      using: :remote,
      screen_size: [1280, 800],
      options: { url: "http://selenium:4444/wd/hub", capabilities: :firefox }
    )
    Capybara.server_host = "0.0.0.0"
    Capybara.server_port = 3001
    Capybara.app_host = "http://app.local:3001"

    def snapshot(name)
      driver = Capybara.current_session.driver
      window = Capybara.current_session.current_window
      current_window_size = window.size

      widths = { desktop: 1280, mobile: 320 }
      widths.each do |platform, width|
        window.resize_to(width, 900)
        total_height = driver.execute_script("return document.body.scrollHeight")
        window.resize_to(width, total_height)
        save_screenshot "tmp/snapshots/#{name}_#{platform}.png"
      end

      # Restore the window size sp other tests aren't affected
      window.resize_to(*current_window_size)
    end
  end
end
