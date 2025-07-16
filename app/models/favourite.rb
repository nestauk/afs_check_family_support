class Favourite < ApplicationRecord
  belongs_to :profile
  belongs_to :provision

  validates :profile_id, uniqueness: {scope: :provision_id}
end
