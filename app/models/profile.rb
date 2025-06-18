class Profile < ApplicationRecord
  validates :child_first_name, :legal_parent_or_carer, :child_date_of_birth, presence: true
end
