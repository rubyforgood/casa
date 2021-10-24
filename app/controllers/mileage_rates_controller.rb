class MileageRatesController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :application, :see_mileage_rate?
    @mileage_rates = MileageRate.all
  end

  def create
  end
end
