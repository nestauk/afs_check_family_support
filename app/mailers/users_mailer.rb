class UsersMailer < ApplicationMailer
  def invite_user
    email = params[:email]
    @signed_email = verifier.generate(["activate", email], expires_in: 1.week)

    mail to: email, subject: "You have been invited to join #{Rails.configuration.application_name}"
  end

  def password_reset
    @user = params[:user]
    @signed_id = @user.generate_token_for(:password_reset)

    mail to: @user.email, subject: "Reset your #{Rails.configuration.application_name} password"
  end

  def confirm_email
    @user = params[:user]
    current_email = params[:current_email]
    @new_email = params[:new_email]

    @signed_email = verifier.generate([@user.id, current_email, @new_email], expires_in: 1.day)

    mail to: @new_email, subject: "Confirm your new #{Rails.configuration.application_name} email address"
  end

  def email_changed
    @user = params[:user]
    old_email = params[:old_email]
    @new_email = params[:new_email]

    mail to: old_email, subject: "Your #{Rails.configuration.application_name} email address has changed"
  end
end
