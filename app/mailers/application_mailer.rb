class ApplicationMailer < ActionMailer::Base
  layout "mailer"

  def verifier
    ActiveSupport::MessageVerifier.new(Rails.configuration.secret_key_base)
  end
end
