class UsersMailer < ApplicationMailer
  def invite_user
    email = params[:email]
    @signed_email = verifier.generate(["activate", email], expires_in: 1.week)

    mail to: email, subject: "You have been invited to join APPLICATION_NAME"
  end

  def password_reset
    @user = params[:user]
    @signed_id = @user.generate_token_for(:password_reset)

    mail to: @user.email, subject: "Reset your APPLICATION_NAME password"
  end

  def confirm_email
    @user = params[:user]
    current_email = params[:current_email]
    @new_email = params[:new_email]

    @signed_email = verifier.generate([@user.id, current_email, @new_email], expires_in: 1.day)

    mail to: @new_email, subject: "Confirm your new APPLICATION_NAME email address"
  end

  def email_changed
    @user = params[:user]
    old_email = params[:old_email]
    @new_email = params[:new_email]

    mail to: old_email, subject: "Your APPLICATION_NAME email address has changed"
  end
end
