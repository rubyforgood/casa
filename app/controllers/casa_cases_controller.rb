class CasaCasesController < ApplicationController
  before_action :set_casa_case, only: %i[show edit update deactivate reactivate copy_court_orders]
  before_action :set_contact_types, only: %i[new edit update create deactivate reactivate]
  before_action :require_organization!
  after_action :verify_authorized

  def index
    authorize CasaCase
    org_cases = current_user.casa_org.casa_cases.includes(:assigned_volunteers)
    @casa_cases = policy_scope(org_cases).includes([:hearing_type, :judge])
    @casa_cases_filter_id = policy(CasaCase).can_see_filters? ? "casa-cases" : ""
    @duties = OtherDuty.where(creator_id: current_user.id)
  end

  def show
    authorize @casa_case

    respond_to do |format|
      format.html {}
      # TODO: add contact topic for generation
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
    @siblings_casa_cases = CasaCasePolicy::Scope.new(current_user, @casa_case).sibling_cases
    authorize @casa_case
  end

  def create
    @casa_case = CasaCase.new(
      casa_case_create_params.merge(
        casa_org: current_organization
      )
    )
    authorize @casa_case

    @casa_case.validate_contact_type = true
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
    original_attributes = @casa_case.full_attributes_hash
    @casa_case.validate_contact_type = true unless current_role == "Volunteer"
    if @casa_case.update_cleaning_contact_types(casa_case_update_params)
      updated_attributes = @casa_case.full_attributes_hash
      changed_attributes_list = CasaCaseChangeService.new(original_attributes, updated_attributes).calculate

      respond_to do |format|
        format.html { redirect_to edit_casa_case_path, notice: "CASA case was successfully updated.#{changed_attributes_list}" }
        format.json { render json: @casa_case, status: :ok }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @casa_case.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def deactivate
    authorize @casa_case, :update_case_status?

    if @casa_case.deactivate
      respond_to do |format|
        format.html do
          flash_message = "Case #{@casa_case.case_number} has been deactivated."
          redirect_to edit_casa_case_path(@casa_case), notice: flash_message
        end

        format.json do
          render json: "Case #{@casa_case.case_number} has been deactivated.", status: :ok
        end
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @casa_case.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def reactivate
    authorize @casa_case, :update_case_status?

    if @casa_case.reactivate
      respond_to do |format|
        format.html do
          flash_message = "Case #{@casa_case.case_number} has been reactivated."
          redirect_to edit_casa_case_path(@casa_case), notice: flash_message
        end

        format.json do
          render json: "Case #{@casa_case.case_number} has been reactivated.", status: :ok
        end
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @casa_case.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def copy_court_orders
    authorize @casa_case, :update_court_orders?
    CasaCase.find_by_case_number(params[:case_number_cp]).case_court_orders.each do |court_order|
      dup_court_order = court_order.dup
      dup_court_order.save
      @casa_case.case_court_orders.append dup_court_order
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_casa_case
    @casa_case = current_organization.casa_cases.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to casa_cases_path, notice: "Sorry, you are not authorized to perform this action." }
      format.json { render json: {error: "Sorry, you are not authorized to perform this action."}, status: :not_found }
    end
  end

  # Only allow a list of trusted parameters through.
  def casa_case_params
    params.require(:casa_case).permit(
      :case_number,
      :birth_month_year_youth,
      :date_in_care,
      :court_report_due_date,
      :empty_court_date,
      casa_case_contact_types_attributes: [:contact_type_id],
      court_dates_attributes: [:date]
    )
  end

  def casa_case_create_params
    create_params = if court_date_unknown?
      casa_case_params.except(:court_dates_attributes)
    else
      casa_case_params
    end

    create_params.except(:empty_court_date)
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

  def court_date_unknown?
    casa_case_params[:empty_court_date] == "1"
  end
end
