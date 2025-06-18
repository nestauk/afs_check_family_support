class ProfilesController < ApplicationController
  def new
    @profile = Profile.new
  end

  def create
    @profile = Profile.new(profile_params)

    if @profile.save
      Service.find_each do |service|
        check = Check.new(profile: @profile, service: service)
        check.compute_eligibility
        check.save!
      end

      redirect_to results_path(@profile)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def results
    @profile = Profile.find_by(id: params[:id])
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
