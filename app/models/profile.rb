class Profile < ApplicationRecord
  has_many :checks

  validates :child_first_name, :legal_parent_or_carer, :child_date_of_birth, presence: true

  def child_age_in_months(at_date = Date.current)
    return nil unless child_date_of_birth.is_a?(Date)

    months_dob = child_date_of_birth.year * 12 + child_date_of_birth.month
    months_at_date = at_date.year * 12 + at_date.month

    difference_in_months = months_at_date - months_dob

    # Adjust for the day of the month to get "completed" months
    if at_date.day < child_date_of_birth.day
      difference_in_months - 1
    else
      difference_in_months
    end
  end
end
