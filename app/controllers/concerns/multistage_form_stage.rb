class MultistageFormStage < ::ApplicationController
  include ActiveModel::Validations

  delegate :track_event, to: :@form
  before_action :save_errors, only: :show

  # These are handled by the parent controller
  skip_before_action :set_current_request_details
  skip_before_action :authenticate_user

  class << self
    attr_accessor :against_validators
  end
  validate :validate_against

  def initialize(multistage_form)
    @form = multistage_form
  end

  def self.validates(name, display: nil, against: nil, **args)
    @attribute_names ||= {}

    # Create an attribute accessor method for any fields that we want to validate
    unless method_defined? name
      define_method name do
        @form.data[name.to_sym]
      end
    end

    # Allow setting a custom human-readable name
    if display
      @attribute_names[name] = display
    end

    if against
      self.against_validators ||= []
      self.against_validators << {field: name, model: against, **args}
    else
      super(name, **args)
    end
  end

  def validate_against
    self.class.against_validators&.each do |against_validator|
      field = against_validator[:field]
      model_class = against_validator[:model]
      model = model_class.new(
        field => @form.data[field],
      )

      model_class.validators_on(field).map do |validator|
        validator.validate(model)
      end

      model.errors[field]&.each do |error|
        errors.add(field, error)
      end
    end
  end

  def self.human_attribute_name(attribute_name, base)
    @attribute_names&.[](attribute_name.to_sym) || super
  end

  def self.valid?(form)
    new(form).valid?
  end

  def self.invalid?(form)
    !new(form).valid?
  end

  def show
    raise StandardError.new "Unhandled action: #{self.class.name}.show"
  end

  def save_errors
    Current.errors ||= {}
    Current.errors.merge!(errors.to_hash(true))
  end

  def self.local_prefixes
    [name.deconstantize.underscore]
  end

  def default_render
    default_template = self.class.name.underscore
    if template_exists?(default_template, variants: request.variant)
      render default_template
    else
      super
    end
  end

  def go_to_stage(stage)
    @form.data[@form.class::STAGE_KEY] = stage.name
    track_event "Changed to stage #{stage.name.demodulize}"
    @form.save_session

    redirect_to @form.form_url
  end
end
