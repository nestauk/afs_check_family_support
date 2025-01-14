module Users
  module Account
    class NameController < ::ApplicationController
      before_action :authenticated

      def edit
      end

      def update
        if Current.user.update(user_params)
          redirect_to users_account_url, success: "Your name was successfully changed"
        else
          render :edit, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.permit(:first_name, :last_name)
      end
    end
  end
end
