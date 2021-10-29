class MileageRatesController < ApplicationController
  after_action :verify_authorized
  before_action :set_mileage_rate, only: %i[edit update]

  def index
    authorize :application, :see_mileage_rate?
    @mileage_rates = MileageRate.all # TODO make these specific to casa orgs
  end

  def new
    authorize CasaAdmin
    @mileage_rate = MileageRate.new(user_id: current_user.id)
  end

  def create
    authorize CasaAdmin
    @mileage_rate = MileageRate.new(mileage_rate_params)

    if @mileage_rate.save
      redirect_to mileage_rates_path
    else
      render :new
    end
  end

  def edit
    authorize CasaAdmin
  end

  def update
    authorize CasaAdmin

    if @mileage_rate.update(mileage_rate_params)
      redirect_to mileage_rates_path
    else
      render :edit
    end
  end

  private

  def mileage_rate_params
    params.require(:mileage_rate).permit(:effective_date, :amount, :is_active, :user_id)
  end

  def set_mileage_rate
    @mileage_rate = MileageRate.find(params[:id])
  end
end
