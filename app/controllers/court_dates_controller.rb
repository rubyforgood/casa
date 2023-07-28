class CourtDatesController < ApplicationController
  before_action :set_casa_case
  before_action :set_court_date, only: %i[edit show generate update destroy]
  before_action :require_organization!

  rescue_from ActiveRecord::RecordNotFound, with: -> { head :not_found }

  def show
    authorize @casa_case

    respond_to do |format|
      format.html {}
      format.docx do
        send_data generate_report_to_string(@court_date, params[:time_zone]),
          type: :docx,
          filename: "#{@court_date.display_name}.docx",
          disposition: "attachment",
          status: :ok
      end
    end
  end

  def new
    @court_date = CourtDate.new(casa_case: @casa_case)
    authorize @court_date
  end

  def edit
    authorize @court_date
  end

  def create
    @court_date = CourtDate.new(court_dates_params.merge(casa_case: @casa_case))
    authorize @court_date

    if !@court_date.date.nil?
      @court_date.court_report_due_date = @court_date.date - 3.weeks
    end

    if @court_date.save && @casa_case.save
      redirect_to casa_case_court_date_path(@casa_case, @court_date), notice: "Court date was successfully created."
    else
      render :new
    end
  end

  def update
    authorize @court_date
    if @court_date.update(court_dates_params)
      redirect_to casa_case_court_date_path(@casa_case, @court_date), notice: "Court date was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    authorize @court_date
    if @court_date.date > Time.now
      @court_date.destroy
      redirect_to casa_case_path(@casa_case), notice: "Court date was successfully deleted."
    else
      redirect_to casa_case_court_date_path(@casa_case, @court_date), notice: "You can delete only future court dates."
    end
  end

  private

  def set_casa_case
    @casa_case = current_organization.casa_cases.friendly.find(params[:casa_case_id])
  end

  def set_court_date
    @court_date = @casa_case.court_dates.find(params[:id])
  end

  def sanitized_params
    params.require(:court_date).tap do |p|
      p[:case_court_orders_attributes]&.reject! do |k, _|
        p[:case_court_orders_attributes][k][:text].blank? && p[:case_court_orders_attributes][k][:implementation_status].blank?
      end

      p[:case_court_orders_attributes]&.each do |k, _|
        p[:case_court_orders_attributes][k][:casa_case_id] = @casa_case.id
      end
    end
  end

  def court_dates_params
    sanitized_params.permit(
      :date,
      :hearing_type_id,
      :judge_id,
      :court_report_due_date,
      {case_court_orders_attributes: %i[text implementation_status id casa_case_id]}
    )
  end

  def generate_report_to_string(court_date, time_zone)
    casa_case = court_date.casa_case
    casa_case.casa_org.open_org_court_report_template do |template_docx_file|
      args = {
        volunteer_id: current_user.volunteer? ? current_user.id : casa_case.assigned_volunteers.first&.id,
        case_id: casa_case.id,
        path_to_template: template_docx_file.to_path,
        time_zone: time_zone,
        court_date: court_date
      }
      context = CaseCourtReportContext.new(args).context
      court_report = CaseCourtReport.new(path_to_template: template_docx_file.to_path, context: context)

      return court_report.generate_to_string
    end
  end
end
