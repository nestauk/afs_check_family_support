module Users
  class PasswordResetController < ::ApplicationController
    # before_action :require_lock, only: :send_password_reset
    before_action :unauthenticated
    before_action :set_user, only: [:set_password, :update_password]

    rate_limit name: "password reset ip limit 1", to: 10, within: 5.minutes, by: -> { "#{request.remote_ip}_1" }, with: -> { send_password_reset_rate_limit }, only: :send_password_reset
    rate_limit name: "password reset ip limit 2", to: 20, within: 20.minutes, by: -> { "#{request.remote_ip}_2" }, with: -> { send_password_reset_rate_limit }, only: :send_password_reset
    rate_limit name: "password reset user limit", to: 1, within: 1.minute, by: -> { params[:email] }, with: -> { send_password_reset_rate_limit }, only: :send_password_reset

    def forgot_password
    end

    def send_password_reset
      if (user = User.find_by(email: params[:email]))
        UsersMailer.with(user:).password_reset.deliver_now
        user.events.create! action: "password_reset_request"
      end
    end

    def set_password
    end

    def update_password
      if @user.update_with_context(user_params, :password_reset)
        @user.events.create! action: "password_reset"
        redirect_to auth_url, success: "Your password was reset successfully. Please sign in."
      else
        render :set_password, status: :unprocessable_entity
      end
    end

    private

    def set_user
      @user = User.find_by_token_for!(:password_reset, params[:sid])
    rescue
      redirect_to users_forgot_password_url, error: "That password reset link is invalid"
    end

    def user_params
      params.permit(:password)
    end

    def send_password_reset_rate_limit
      Current.errors[:form] = "Too many attempts. Please try again later."

      user = User.find_by(email: params[:email])
      user&.events&.create! action: "rate_limited", data: {for: "forgot_password"}

      render :forgot_password, status: :unprocessable_entity
    end
  end
end
