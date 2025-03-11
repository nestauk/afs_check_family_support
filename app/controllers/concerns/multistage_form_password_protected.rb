class MultistageFormPasswordProtected < MultistageFormStage
  validates :password, presence: true
  def show
    render "multistage_form/password_protected"
  end

  def next_action
    if params[:password] != @form.password
      errors.add(:password, :invalid)

      raise_validation_error
    end

    @form.go_to_stage @form.stages.first
  end
end
