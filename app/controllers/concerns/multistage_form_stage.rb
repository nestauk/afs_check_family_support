class MultistageFormStage < ::ApplicationController
  include ActiveModel::Validations

  delegate :track_event, to: :@form
  before_action :save_errors, only: :show

  def initialize(multistage_form)
    @form = multistage_form
  end

  def self.validates(name, **args)
    @attribute_names ||= {}

    # Create an attribute accessor method for any fields that we want to validate
    unless method_defined? name
      define_method name do
        @form.data[name.to_sym]
      end
    end

    # Allow setting a custom human-readable name
    if args.has_key?(:display)
      @attribute_names[name] = args.delete :display
    end

    super
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

  def default_render
    default_template = self.class.name.underscore
    if template_exists?(default_template, variants: request.variant)
      return render default_template
    end

    super
  end
end
