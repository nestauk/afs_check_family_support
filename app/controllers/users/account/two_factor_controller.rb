module Users
  module Account
    class TwoFactorController < ::ApplicationController
      before_action :authenticated
      before_action :ensure_disabled, only: [:disable, :deactivate]
      before_action :ensure_enabled, only: [:enable, :activate]
      before_action :setup_totp, only: [:enable, :activate]

      def disable
      end

      def deactivate
        if Current.user.update_with_context({otp_secret: nil, password_challenge: params[:password_challenge]}, :disable_2fa)
          Current.user.events.create! action: "two_factor_deactivated"

          redirect_to users_account_url, success: "Two factor authentication has been successfully disabled"
        else
          Current.user.events.create! action: "invalid_password_challenge", data: {for: "deactivate_2fa"}

          render :disable, status: :unprocessable_entity
        end
      end

      def enable
        @qr_code = RQRCode::QRCode.new(@totp.provisioning_uri(Current.user.email))
      end

      def activate
        if @totp.verify(params[:totp], drift_behind: 15)
          Current.user.update otp_secret: @otp_secret
          session.delete :otp_secret
          Current.user.events.create! action: "two_factor_activated"

          redirect_to users_account_url, success: "Two factor authentication has been successfully enabled"
        else
          Current.errors[:totp] = "That verification code didn't work. Please try again."
          @qr_code = RQRCode::QRCode.new(@totp.provisioning_uri(Current.user.email))

          render :enable, status: :unprocessable_entity
        end
      end

      private

      def ensure_enabled
        if Current.user.otp_secret.present?
          redirect_to users_account_disable_2fa_url
        end
      end

      def ensure_disabled
        if Current.user.otp_secret.nil?
          redirect_to users_account_enable_2fa_url
        end
      end

      def setup_totp
        session[:otp_secret] ||= ROTP::Base32.random
        @otp_secret = session[:otp_secret]
        @totp = ROTP::TOTP.new(session[:otp_secret], issuer: "APPLICATION_NAME")
      end
    end
  end
end
