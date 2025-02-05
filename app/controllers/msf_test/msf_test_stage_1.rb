module MsfTest
  class MsfTestStage1 < ::MultistageFormStage
    validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}

    def show
    end

    def next_action
      validate!

      @form.go_to_stage MsfTestStage2
    end
  end
end
