class ProvidersController < ApplicationController
  def new
    @provider = Provider.new
    Service.find_each { |service| @provider.provisions.build(service: service) }
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
    params.require(:provider).permit(
      :name,
      provisions_attributes: [:id, :service_id, :how_to_sign_up, :selected],
    )
  end
end
