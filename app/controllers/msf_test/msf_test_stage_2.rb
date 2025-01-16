module MsfTest
  class MsfTestStage2 < ::MultistageFormStage
    def show
    end

    def back_action
      @form.go_to_stage MsfTestStage1
    end
  end
end
