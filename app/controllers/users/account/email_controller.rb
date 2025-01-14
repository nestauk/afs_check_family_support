module Users
  module Account
    class EmailController < ::ApplicationController
      before_action :authenticated
      before_action :verify_change_email_token, only: [:confirm, :update]

      def edit
      end

      def send_verification
        current_email = Current.user.email
        new_email = user_params[:email]

        if current_email == new_email
          Current.errors[:email] = "That email is already associated with your account"

          return render :edit, status: :unprocessable_entity
        end

        Current.user.email = new_email

        if Current.user.valid?
          UsersMailer.with(user: Current.user, current_email:, new_email:).confirm_email.deliver_now
          Current.user.events.create! action: "email_change_request", data: {to: new_email}

          redirect_to users_account_url, success: "A confirmation email was sent to #{new_email}"
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def confirm
      end

      def update
        old_email = Current.user.email
        if Current.user.update_with_context({email: @new_email, password_challenge: params[:password_challenge]}, :change_email)
          UsersMailer.with(user: Current.user, old_email:, new_email: @new_email).email_changed.deliver_now
          Current.user.events.create! action: "email_changed", data: {from: old_email}

          redirect_to users_account_url, success: "Your email address has been updated successfully"
        else
          Current.user.events.create! action: "invalid_password_challenge", data: {for: "change_email"}

          render :confirm, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.permit(:email)
      end

      def verify_change_email_token
        user_id, current_email, @new_email = verifier.verified(params[:signed_email])

        if user_id != Current.user.id || current_email != Current.user.email
          redirect_to users_account_url, error: "That link has expired"
        end
      end
    end
  end
end
