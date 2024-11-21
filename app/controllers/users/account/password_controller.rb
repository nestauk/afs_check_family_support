module Users
  module Account
    class PasswordController < ::ApplicationController
      before_action :authenticated

      def edit
      end

      def update
        if Current.user.update_with_context(user_params, :update_password)
          Current.user.events.create! action: "password_changed"

          redirect_to users_account_url, success: "Your password was successfully changed"
        else
          Current.user.events.create! action: "invalid_password_challenge", data: {for: "change_password"}

          render :edit, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.permit(:password, :password_challenge)
      end
    end
  end
end
