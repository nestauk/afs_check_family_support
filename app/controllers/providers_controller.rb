class ProvidersController < ApplicationController
  def new
    @provider = Provider.new
  end

  def create
    @provider = Provider.new(provider_params)

    if @provider.save
      redirect_to provider_path(@provider)
    else
      render :new
    end
  end

  def show
    @provider = Provider.find_by(id: params[:id])
  end

  private

  def provider_params
    params.require(:provider).permit(:name, service_ids: [])
  end
end
