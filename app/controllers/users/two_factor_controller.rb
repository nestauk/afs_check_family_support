module Users
  class TwoFactorController < ::ApplicationController
    before_action :require_unauthenticated, :set_user
    rate_limit name: "totp ip limit 1", to: 50, within: 5.minutes, by: -> { "#{request.remote_ip}_1" }, with: -> { verify_rate_limit }, only: :verify
    rate_limit name: "totp ip limit 2", to: 100, within: 20.minutes, by: -> { "#{request.remote_ip}_2" }, with: -> { verify_rate_limit }, only: :verify
    rate_limit name: "totp user limit 1", to: 3, within: 75.seconds, by: -> { "#{@user.id}_1" }, with: -> { verify_rate_limit }, only: :verify
    rate_limit name: "totp user limit 2", to: 10, within: 20.minutes, by: -> { "#{@user.id}_2" }, with: -> { verify_rate_limit }, only: :verify

    def challenge
    end

    def verify
      @totp = ROTP::TOTP.new(@user.otp_secret, issuer: "APPLICATION_NAME")

      if @totp.verify(params[:totp]&.strip || "", drift_behind: 15)
        clear_rate_limit ["#{@user.id}_1", "#{@user.id}_2"]
        reset_session
        session[:user_id] = @user.id
        @user.events.create! action: "successful_totp_challenge"

        redirect_to dashboard_url, notice: "Signed in successfully"
      else
        Current.errors[:totp] = "That verification code didn't work. Please try again."
        @user.events.create! action: "invalid_totp_challenge"

        render :challenge, status: :unprocessable_entity
      end
    end

    private

    def set_user
      if session[:challenge_token].nil?
        return redirect_to auth_url
      end

      @user = User.find_signed(session[:challenge_token], purpose: :authentication_challenge)

      if @user.nil?
        redirect_to auth_url, alert: "Authenticated session expired. Please try again."
      end
    end

    def verify_rate_limit
      @user.events.create! action: "rate_limited", data: {for: "two_factor"}

      reset_session
      redirect_to auth_url, error: "Too many attempts. Please try again later."
    end
  end
end
