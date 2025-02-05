ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors, threshold: 15)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Allow factories to be used in all tests
  include FactoryBot::Syntax::Methods

  # Add more helper methods to be used by all tests here...
  def verifier
    ActiveSupport::MessageVerifier.new(Rails.configuration.secret_key_base)
  end

  def assert_event user, action, **data
    event = user.events.where(action: action).first

    assert_not_nil event, "Event \"#{action}\" for user \"#{user.email}\" does not exist"
    data.each do |key, value|
      assert_equal value, event.data[key.to_s]
    end
  end
end
