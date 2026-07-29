class MileageRatesController < ApplicationController
  layout "casa_app"
  before_action -> { @active_nav = "settings" }
  after_action :verify_authorized
  skip_after_action :verify_policy_scoped # TODO: index should call policy_scope; remove this skip once it does
  before_action :set_mileage_rate, only: %i[edit update]

  def index
    authorize :application, :see_mileage_rate?
    @mileage_rates = MileageRate.where(casa_org: current_organization).order(effective_date: :asc)
  end

  def new
    @mileage_rate = current_organization.mileage_rates.build
    authorize @mileage_rate
  end

  def create
    @mileage_rate = MileageRate.new(mileage_rate_params.merge(casa_org: current_organization))
    authorize @mileage_rate
    if @mileage_rate.save
      redirect_to mileage_rates_path
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @mileage_rate
  end

  def update
    authorize @mileage_rate

    if @mileage_rate.update(mileage_rate_params)
      redirect_to mileage_rates_path
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def mileage_rate_params
    params.require(:mileage_rate).permit(:effective_date, :amount, :is_active)
  end

  # Scoped to the org: an unscoped find let an admin reach another org's rate, and a 404 is the
  # right answer there rather than leaving it to the policy alone.
  def set_mileage_rate
    @mileage_rate = current_organization.mileage_rates.find(params[:id])
  end
end
