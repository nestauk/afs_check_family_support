class Check < ApplicationRecord
  belongs_to :profile
  belongs_to :service

  validates :eligible, inclusion: {in: [true, false]}

  def compute_eligibility
    eligibility = []
    self[:reasons] = []

    [:age, :parent_carer_status_required].each do |criterion|
      result = send(criterion)
      eligibility << result[:eligible]
      self[:reasons] << result[:reason]
    end
    self[:eligible] = eligibility.all?(true)
    self[:reasons] = self[:reasons].uniq
    [eligible, reasons]
  end

  def age
    return {eligible: true, reason: "The service has no age limits"} if
      service.eligible_min_child_age_months.blank? && service.eligible_max_child_age_months.blank?

    return {eligible: false, reason: "Your child is too young"} if
      profile.child_age_in_months < service.eligible_min_child_age_months

    return {eligible: false, reason: "Your child is too old"} if
      profile.child_age_in_months > service.eligible_max_child_age_months

    {eligible: true, reason: "Your child is within the age limits"}
  end

  def parent_carer_status_required
    return {eligible: true, reason: "The service does not require a parent or carer"} if
      service.eligible_parent_carer_status_required.blank? || service.eligible_parent_carer_status_required == false

    return {eligible: false, reason: "You must be a parent or carer to access this service"} unless
      profile.legal_parent_or_carer

    {eligible: true, reason: "You are a legal parent or carer"}
  end
end
