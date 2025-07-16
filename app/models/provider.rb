class Provider < ApplicationRecord
  has_many :provisions, dependent: :destroy
  has_many :services, through: :provisions

  validates :name, presence: true
end
