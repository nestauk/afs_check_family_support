class ApplicationMailer < ActionMailer::Base
  layout "mailer"
  helper :application

  def application_name
    Rails.configuration.application_name
  end

  def verifier
    ActiveSupport::MessageVerifier.new(Rails.configuration.secret_key_base)
  end
end
