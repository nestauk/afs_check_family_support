module Users
  module Account
    class ActivationController < ::ApplicationController
      before_action :unauthenticated
      before_action :verify_activation_token

      def new
      end

      def create
        user = User.new(user_params.merge(email: @email))

        if user.save
          redirect_to auth_url, success: "Your account has been activated! Please login to continue."
        else
          render :new, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.permit(:first_name, :last_name, :password)
      end

      def verify_activation_token
        key, @email = verifier.verified(params[:signed_email])

        if key != "activate"
          redirect_to auth_url, error: "That activation link has expired"
        end

        if User.where(email: @email).exists?
          redirect_to auth_url, error: "You have already activated your account. Please login to continue."
        end
      end
    end
  end
end
