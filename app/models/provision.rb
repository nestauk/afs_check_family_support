class Provision < ApplicationRecord
  belongs_to :provider
  belongs_to :service

  has_many :favourites, dependent: :destroy

  attr_accessor :selected
end
