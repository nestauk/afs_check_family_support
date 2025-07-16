class FavouritesController < ApplicationController
  before_action :set_profile
  before_action :set_provision, only: %i[create destroy]

  def create
    @favourite = Favourite.create(profile: @profile, provision: @provision)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @profile } # Fallback for non-JS clients
    end
  end

  def index
    @favourites = Favourite.where(profile_id: params[:id])
  end

  def destroy
    @favourite = Favourite.find_by(profile_id: params[:id], provision_id: params[:provision_id])
    @favourite.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @profile, status: :see_other } # Fallback for non-JS clients
    end
  end

  private

  def set_profile
    @profile = Profile.find(params[:id])
  end

  def set_provision
    @provision = Provision.find(params[:provision_id])
  end
end
