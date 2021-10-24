class MileageRatesController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :application, :see_mileage_rate?
    @mileage_rates = MileageRate.all
  end

  def new
    authorize CasaAdmin
    @mileage_rate = MileageRate.new(user_id: current_user.id)
  end

  def create
    authorize CasaAdmin
    @mileage_rate = MileageRate.new(create_mileage_rate_params)

    if @mileage_rate.save
      redirect_to mileage_rates_path
    else
      render :new
    end
  end

  private

  def create_mileage_rate_params
    params.require(:mileage_rate).permit(:effective_date, :amount, :is_active, :user_id)
  end
end
