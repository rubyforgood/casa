class CasaCasesController < ApplicationController
  before_action :set_casa_case, only: %i[show edit update destroy deactivate reactivate]
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
        send_data csv, filename: "volunteer-#{current_user.id}-case-contacts-#{Time.zone.now.to_i}.csv"
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

    respond_to do |format|
      if @casa_case.save
        format.html { redirect_to @casa_case, notice: "CASA case was successfully created." }
        format.json { render :show, status: :created, location: @casa_case }
      else
        format.html { render :new }
        format.json { render json: @casa_case.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @casa_case
    respond_to do |format|
      if @casa_case.update_cleaning_contact_types(casa_case_update_params)
        format.html { redirect_to edit_casa_case_path, notice: "CASA case was successfully updated." }
        format.json { render :show, status: :ok, location: @casa_case }
      else
        format.html { render :edit }
        format.json { render json: @casa_case.errors, status: :unprocessable_entity }
      end
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
      :court_date,
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
end
