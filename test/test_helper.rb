ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors, threshold: 15)

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

  def assert_email(recipient, subject)
    deliveries = ActionMailer::Base.deliveries
    email = deliveries.find { |e| e.to[0] == recipient && e.subject == subject }
    assert email, "Expected to find email to #{recipient} with subject #{subject}."
    email
  end

  def sign_in(user = @user)
    visit auth_path
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Sign in"
    assert_text "Signed in successfully"
  end

  def click_email_link(text)
    html = Nokogiri::HTML(ActionMailer::Base.deliveries.last.html_part.body.to_s)
    visit html.at("a:contains(\"#{text}\")")["href"]

    self
  end

  def take_snapshot(name)
    @then.i_take_snapshot(name)
  end

  def assert_page_is_accessible
    @then.the_page_is_accessible
  end
end
