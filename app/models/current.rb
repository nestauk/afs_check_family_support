class Current < ActiveSupport::CurrentAttributes
  attribute :user, :user_agent, :ip_address
  attribute :errors
end
