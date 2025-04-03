module Users::Account::Activation
  class Stage2Password < ::MultistageFormStage
    validates :password, against: User

    def show
    end

    def back_action
      go_to_stage Stage1Name
    end

    def submit_action
      validate!

      user = User.new(
        email: @form.email,
        **@form.data.slice(:first_name, :last_name, :password),
      )
      user.save!

      @form.clear_session

      redirect_to auth_url, success: "Your account has been activated! Please login to continue."
    end
  end
end
