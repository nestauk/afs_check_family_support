module Users::Account::Activation
  class Stage1Name < ::MultistageFormStage
    validates :first_name, against: User
    validates :last_name, against: User

    def show
    end

    def next_action
      validate!

      go_to_stage Stage2Password
    end
  end
end
