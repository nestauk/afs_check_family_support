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
end
