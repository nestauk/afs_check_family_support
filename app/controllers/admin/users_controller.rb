module Admin
  class UsersController < AdminController
    include Pagy::Backend

    before_action :set_user, except: [:index, :invite, :send_invitation]

    def index
      @pagy, @users = pagy(User.all)
    end

    def invite
    end

    def send_invitation
      emails = params[:emails].is_a?(Array) ? params[:emails].compact_blank.uniq : []
      if emails.count == 0
        Current.errors[:form] = "Please enter at least one email address"

        return render :invite, status: :unprocessable_content
      end

      user_emails = User.select("email").where(email: emails).pluck(:email)
      emails.each_with_index do |email, i|
        unless email.match? "@"
          Current.errors[:emails] ||= []
          Current.errors[:emails][i] = "Please enter a valid email address"
        end
        if user_emails.include? email
          Current.errors[:emails] ||= []
          Current.errors[:emails][i] = "That user already exists"
        end
      end
      if Current.errors.has_key?(:emails)
        return render :invite, status: :unprocessable_content
      end

      emails.each do |email|
        UsersMailer.with(email: email.strip).invite_user.deliver_now
        Current.user.events.create! action: "admin_users_invite_sent", data: {to: email}
      end

      redirect_to admin_users_url, success: "Invitations were successfully sent"
    end

    def show
    end

    def change_email
    end

    def send_email_verification
      current_email = @user.email
      new_email = params[:email]

      if current_email == new_email
        Current.errors[:email] = "That email is already associated with that account"

        return render :change_email, status: :unprocessable_entity
      end

      @user.email = new_email

      if @user.valid?
        UsersMailer.with(user: @user, current_email:, new_email:).confirm_email.deliver_now
        @user.events.create! action: "email_change_request", data: {to: new_email, by: Current.user.id}
        Current.user.events.create! action: "admin_user_email_change_request", data: {for: @user.id}

        redirect_to admin_user_url(@user), success: "A confirmation email was sent to #{new_email}"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def enable_admin
      @user.update! is_admin: true

      @user.events.create! action: "admin_enabled", data: {by: Current.user.id}
      Current.user.events.create! action: "admin_user_admin_enabled", data: {for: @user.id}

      redirect_to admin_user_url(@user), success: "Admin status was successfully granted"
    end

    def disable_admin
      @user.update! is_admin: false

      @user.events.create! action: "admin_disabled", data: {by: Current.user.id}
      Current.user.events.create! action: "admin_user_admin_disabled", data: {for: @user.id}

      redirect_to admin_user_url(@user), success: "Admin status was successfully revoked"
    end

    def password_reset
      UsersMailer.with(user: @user).password_reset.deliver_now

      @user.events.create! action: "password_reset_request", data: {by: Current.user.id}
      Current.user.events.create! action: "admin_user_password_reset_request", data: {for: @user.id}

      redirect_to admin_user_url(@user), success: "A password reset link was sent to #{@user.email}"
    end

    def deactivate_2fa
      @user.otp_secret = nil
      @user.update! otp_secret: nil

      @user.events.create! action: "two_factor_deactivated", data: {by: Current.user.id}
      Current.user.events.create! action: "admin_user_two_factor_deactivated", data: {for: @user.id}

      redirect_to admin_user_url(@user), success: "Two factor authentication was successfully disabled"
    end

    private

    def set_user
      @user = User.find(params[:id] || params[:user_id])
    end
  end
end
