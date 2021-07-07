class PastCourtDatesController < ApplicationController
  before_action :set_casa_case, only: %i[show index]
  before_action :set_past_court_date, only: %i[show generate]
  before_action :require_organization!

  rescue_from ActiveRecord::RecordNotFound, with: -> { head :not_found }

  def index
    @past_court_dates = @casa_case.past_court_dates
  end

  def show
    authorize @casa_case

    respond_to do |format|
      format.html {}
      format.docx do
        send_data(
          @past_court_date.generate_report,
          type: :docx,
          filename: "#{@past_court_date.display_name}.docx",
          disposition: "attachment",
          status: :ok
        )
      end
    end
  end

  private

  def set_casa_case
    @casa_case = current_organization.casa_cases.find(params[:casa_case_id])
  end

  def set_past_court_date
    @past_court_date = @casa_case.past_court_dates.find(params[:id])
  end
end
