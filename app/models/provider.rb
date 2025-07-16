class Provider < ApplicationRecord
  has_many :provisions, dependent: :destroy
  has_many :services, through: :provisions

  accepts_nested_attributes_for :provisions,
    reject_if: proc { |attrs| attrs["selected"].in?(["0", false]) }

  validates :name, presence: true
end
