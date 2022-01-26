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
    original_attributes = @casa_case.full_attributes_hash

    if @casa_case.update_cleaning_contact_types(casa_case_update_params)
      updated_attributes = @casa_case.full_attributes_hash
      changed_attributes_list = html_formatted_list(changed_attributes_messages(original_attributes, updated_attributes))

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

  def html_formatted_list(messages)
    html_string = messages&.join("</li><li>")
    if html_string.present?
      "<ul><li>#{html_string}</li></ul>"
    end
  end

  def changed_attributes_messages(original, changed)
    changed_attributes = changed.select { |k, v| original[k] != v }.keys.delete_if { |k| k == :updated_at }
    return if changed_attributes.empty?

    changed_attributes.map do |att|
      change_message_text(att, original[att], changed[att])
    end.delete_if(&:nil?)
  end

  def change_message_text(attribute, original_attribute, updated_attribute)
    if attribute == :contact_types
      new_contact_type_ids = updated_attribute.map { |contact| contact["contact_type_id"] }
      previous_contact_type_ids = original_attribute.map { |contact| contact["contact_type_id"] }
      changed_count = new_contact_type_ids - previous_contact_type_ids
      return if changed_count == 0
      "#{changed_count} #{attribute.to_s.humanize.singularize.pluralize(changed_count)} added"
    elsif attribute == :court_orders
      changed_count = (updated_attribute - original_attribute).count
      "#{changed_count} #{attribute.to_s.humanize.singularize.pluralize(changed_count)} added or updated"
    else
      "Changed #{attribute.to_s.gsub(/_id\Z/, "").humanize}"
    end
  end
end
