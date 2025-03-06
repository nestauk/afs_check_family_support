class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  after_validation :save_errors

  def update_with_context(new_attributes, context)
    with_transaction_returning_status do
      assign_attributes(new_attributes)
      save(context: context)
    end
  end

  def save_errors
    Current.errors ||= {}
    Current.errors = Current.errors.merge!(errors.to_hash(true))
  end

  def self.validates(*attributes, **args)
    # Allow setting a custom human-readable name for validations
    if args.has_key?(:display)
      @human_attribute_names ||= {}
      @human_attribute_names[attributes.first] = args.delete :display
    end

    super
  end

  def self.human_attribute_name(attribute_name, base)
    @human_attribute_names&.[](attribute_name.to_sym) || super
  end
end
