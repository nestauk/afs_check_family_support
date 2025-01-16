class MultistageFormStage < ::ApplicationController
  include ActiveModel::Validations

  before_action :save_errors, only: :show

  def initialize(multistage_form)
    @form = multistage_form
  end

  def show
    raise StandardError.new "Unhandled action: #{self.class.name}.show"
  end

  def save_errors
    Current.errors ||= {}
    Current.errors.merge!(errors.to_hash(true))
  end

  def respond_to_missing?
    true
  end

  def method_missing(name)
    @form.data[name.to_sym]
  end
end