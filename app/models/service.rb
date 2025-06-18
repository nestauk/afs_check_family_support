class Service < ApplicationRecord
  CONCERNS = [
    "Child behaviour problems",
    "Communication difficulties",
    "Developmental delays",
    "Emotional regulation",
    "Safety concerns",
    "Other",
  ].freeze
  CIRCUMSTANCES = [
    "Domestic abuse",
    "Housing problems",
    "Income difficulties",
    "Parental mental health",
    "Parental physical health",
    "Social exclusion",
    "Substance use",
    "Young carer",
    "Other",
  ].freeze

  validates :name, :description, presence: true
  validates :eligible_developmental_concerns, inclusion: {in: CONCERNS, allow_blank: true}
  validates :eligible_circumstances, inclusion: {in: CIRCUMSTANCES, allow_blank: true}
end
