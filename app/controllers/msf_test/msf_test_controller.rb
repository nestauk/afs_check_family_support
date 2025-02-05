module MsfTest
  class MsfTestController < ::MultistageFormController
    def initialize
      super MsfTestStage1
    end

    def form_url
      msf_test_url
    end
  end
end
