class ServicesController < ApplicationController
  def show
    @service = Service.find_by(id: params[:id])
    @check = Check.find_by(id: params[:check_id])
  end
end
