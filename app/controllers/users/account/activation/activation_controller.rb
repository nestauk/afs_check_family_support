module Users::Account::Activation
  class ActivationController < ::MultistageFormController
    before_action :require_unauthenticated
    before_action :verify_activation_token

    attr_accessor :email

    def initialize
      add_stage Stage1Name
      add_stage Stage2Password
    end

    private

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
