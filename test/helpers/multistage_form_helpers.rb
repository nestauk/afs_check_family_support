module MultistageFormHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def controller(controller)
      define_method :controller do
        controller
      end
    end
  end

  # Reset our cached form data when we make a new request
  def process(*)
    super

    @form_data = nil
  end

  def form_data
    @form_data ||= session[:"#{controller.name}.data"]
  end

  def set_form_data(**data)
    if data[:_stage]&.is_a?(MultistageFormStage)
      data[:_stage] = data[:_stage].name
    end

    set_session "#{controller.name}.data": data
  end

  def assert_stage(stage)
    assert_equal(stage.name, form_data[:_stage])
  end
end
