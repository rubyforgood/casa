class CasaCasesController < ApplicationController
  before_action :set_casa_case, only: %i[show edit update deactivate reactivate]
  before_action :set_contact_types, only: %i[new edit update create deactivate]
  before_action :require_organization!
  after_action :verify_authorized

  def index
    authorize CasaCase
    org_cases = current_user.casa_org.casa_cases.includes(:assigned_volunteers)
    @casa_cases = policy_scope(org_cases).includes([:hearing_type, :judge])
    @casa_cases_filter_id = policy(CasaCase).can_see_filters? ? "casa-cases" : ""
  end

  def show
    authorize @casa_case

    respond_to do |format|
      format.html {}
      format.csv do
        case_contacts = @casa_case.decorate.case_contacts_ordered_by_occurred_at
        csv = CaseContactsExportCsvService.new(case_contacts).perform
        send_data csv, filename: case_contact_csv_name(case_contacts)
      end
      format.xlsx do
        filename = @casa_case.case_number + "-case-contacts-" + Time.now.strftime("%Y-%m-%d") + ".xlsx"
        response.headers["Content-Disposition"] = "attachment; filename=#{filename}"
      end
    end
  end

  def new
    @casa_case = CasaCase.new(casa_org: current_organization)
    authorize @casa_case
  end

  def edit
    authorize @casa_case
  end

  def create
    @casa_case = CasaCase.new(casa_case_params.merge(casa_org: current_organization))
    authorize @casa_case

    if @casa_case.save
      respond_to do |format|
        format.html { redirect_to @casa_case, notice: "CASA case was successfully created." }
        format.json { render json: @casa_case, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: @casa_case.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @casa_case
    if @casa_case.update_cleaning_contact_types(casa_case_update_params)
      redirect_to edit_casa_case_path, notice: "CASA case was successfully updated."
    else
      render :edit
    end
  end

  def deactivate
    authorize @casa_case, :update_case_status?

    if @casa_case.deactivate
      flash_message = "Case #{@casa_case.case_number} has been deactivated."
      redirect_to edit_casa_case_path(@casa_case), notice: flash_message
    else
      render :edit
    end
  end

  def reactivate
    authorize @casa_case, :update_case_status?

    if @casa_case.reactivate
      flash_message = "Case #{@casa_case.case_number} has been reactivated."
      redirect_to edit_casa_case_path(@casa_case), notice: flash_message
    else
      render :edit
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_casa_case
    @casa_case = current_organization.casa_cases.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  # Only allow a list of trusted parameters through.
  def casa_case_params
    params.require(:casa_case).permit(
      :case_number,
      :transition_aged_youth,
      :birth_month_year_youth,
      :court_report_due_date,
      :hearing_type_id,
      :judge_id
    )
  end

  # Separate params so only admins can update the case_number
  def casa_case_update_params
    params.require(:casa_case).permit(policy(@casa_case).permitted_attributes)
  end

  def set_contact_types
    @contact_types = ContactType.for_organization(current_organization)
  end

  def case_contact_csv_name(case_contacts)
    casa_case_number = case_contacts&.first&.casa_case&.case_number
    current_date = Time.now.strftime("%Y-%m-%d")

    "#{casa_case_number.nil? ? "" : casa_case_number + "-"}case-contacts-#{current_date}.csv"
  end
end
