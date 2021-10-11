class PastCourtDatesController < ApplicationController
  before_action :set_casa_case
  before_action :set_past_court_date, only: %i[edit show generate update]
  before_action :require_organization!

  rescue_from ActiveRecord::RecordNotFound, with: -> { head :not_found }

  def show
    authorize @casa_case

    respond_to do |format|
      format.html {}
      format.docx do
        send_data @past_court_date.generate_report,
          type: :docx,
          filename: "#{@past_court_date.display_name}.docx",
          disposition: "attachment",
          status: :ok
      end
    end
  end

  def new
    @past_court_date = PastCourtDate.new(casa_case: @casa_case)
    authorize @past_court_date
  end

  def edit
    authorize @past_court_date
  end

  def create
    @past_court_date = PastCourtDate.new(past_court_dates_params.merge(casa_case: @casa_case))
    authorize @past_court_date

    if @past_court_date.save
      redirect_to casa_case_past_court_date_path(@casa_case, @past_court_date), notice: "Past court date was successfully created."
    else
      render :new
    end
  end

  def update
    authorize @past_court_date
    if @past_court_date.update(past_court_dates_params)
      redirect_to casa_case_past_court_date_path(@casa_case, @past_court_date), notice: "Past court date was successfully updated."
    else
      render :edit
    end
  end

  private

  def set_casa_case
    @casa_case = current_organization.casa_cases.find(params[:casa_case_id])
  end

  def set_past_court_date
    @past_court_date = @casa_case.past_court_dates.find(params[:id])
  end

  def past_court_dates_params
    params.require(:past_court_date).permit(
      :date,
      :hearing_type_id,
      :judge_id,
      {case_court_orders_attributes: %i[text implementation_status id casa_case_id]}
    )
  end
end
