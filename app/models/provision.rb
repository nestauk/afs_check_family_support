class Provision < ApplicationRecord
  belongs_to :provider
  belongs_to :service
end
