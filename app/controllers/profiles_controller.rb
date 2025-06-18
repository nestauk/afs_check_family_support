class ProfilesController < ApplicationController
  def new
    @profile = Profile.new
  end

  def create
    @profile = Profile.new(profile_params)

    if @profile.save
      redirect_to results_path, notice: "Profile was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:profile).permit(
      :child_first_name,
      :legal_parent_or_carer,
      :child_date_of_birth,
      :current_post_code,
      :existing_professional_involvement,
      :developmental_concerns,
      :circumstances,
      :motivated,
    )
  end
end
