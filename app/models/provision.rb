class Provision < ApplicationRecord
  belongs_to :provider
  belongs_to :service

  attr_accessor :selected
end
