module Users
  class AuthenticationController < ::ApplicationController
    before_action :unauthenticated, except: [:sign_out]
    rate_limit name: "auth ip limit 1", to: 50, within: 5.minutes, by: -> { "#{request.remote_ip}_1" }, with: -> { auth_rate_limit }, only: :authenticate
    rate_limit name: "auth ip limit 2", to: 100, within: 20.minutes, by: -> { "#{request.remote_ip}_2" }, with: -> { auth_rate_limit }, only: :authenticate
    rate_limit name: "auth email limit 1", to: 5, within: 5.minutes, by: -> { "#{params[:email]}_1" }, with: -> { auth_rate_limit }, only: :authenticate
    rate_limit name: "auth email limit 2", to: 10, within: 20.minutes, by: -> { "#{params[:email]}_2" }, with: -> { auth_rate_limit }, only: :authenticate

    def sign_in
    end

    def authenticate
      # Always perform both of these queries to prevent timing attacks
      user = User.find_by(email: params[:email])
      if User.authenticate_by(email: params[:email], password: params[:password])
        clear_rate_limit ["#{params[:email]}_1", "#{params[:email]}_2"]
        reset_session

        if user.otp_secret
          session[:challenge_token] = user.signed_id(purpose: :authentication_challenge, expires_in: 15.minutes)
          user.events.create! action: "successful_password_challenge", data: {for: "sign_in"}
          user.events.create! action: "totp_challenge"

          redirect_to auth_2fa_url
        else
          session[:user_id] = user.id
          user.events.create! action: "successful_password_challenge", data: {for: "sign_in"}

          redirect_to dashboard_url, notice: "Signed in successfully"
        end
      else
        Current.errors[:form] = "Those details do not match. Please try again."
        user&.events&.create! action: "invalid_password_challenge", data: {for: "sign_in"}

        render :sign_in, status: :unprocessable_entity
      end
    end

    def sign_out
      Current.user&.events&.create! action: "sign_out"
      reset_session

      redirect_to auth_url
    end

    def auth_rate_limit
      Current.errors[:form] = "Too many attempts. Please try again later."

      user = User.find_by(email: params[:email])
      user&.events&.create! action: "rate_limited", data: {for: "sign_in"}

      render :sign_in, status: :unprocessable_entity
    end

    def verify_rate_limit
      Current.errors[:form] = "Too many attempts. Please try again later."

      user = User.find_by(email: params[:email])
      user&.events&.create! action: "rate_limited", data: {for: "sign_in"}

      render :sign_in, status: :unprocessable_entity
    end
  end
end
