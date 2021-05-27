class PastCourtDatesController < ApplicationController
  before_action :set_casa_case, only: %i[show]
  before_action :set_past_court_date, only: %i[show]
  before_action :require_organization!

  def show
    authorize @casa_case
  end

  private

  def set_casa_case
    @casa_case = current_organization.casa_cases.find(params[:casa_case_id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def set_past_court_date
    @past_court_date = @casa_case.past_court_dates.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end
end
