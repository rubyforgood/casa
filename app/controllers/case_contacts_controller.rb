# CaseContactsController with default actions
class CaseContactsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_case_contact, only: %i[edit update destroy]
  before_action :set_contact_types, only: %i[new edit update create]
  before_action :require_organization!

  # GET /case_contacts
  # GET /case_contacts.json
  def index
    org_cases = CasaOrg.includes(:casa_cases).references(:casa_cases).find_by(id: current_user.casa_org_id).casa_cases
    @casa_cases = policy_scope(org_cases)
    @case_contacts = policy_scope(current_organization.case_contacts).decorate
  end

  # GET /case_contacts/new
  def new
    @casa_cases = policy_scope(current_organization.casa_cases)

    # Admins and supervisors who are navigating to this page from a specific
    # case detail page will only see that case as an option
    if params.dig(:case_contact, :casa_case_id).present?
      @casa_cases = @casa_cases.where(id: params.dig(:case_contact, :casa_case_id))
    end

    @case_contact = CaseContact.new

    # By default the first case is selected
    @selected_cases = @casa_cases[0, 1]

    @current_organization_groups = current_organization.contact_type_groups.joins(:contact_types).where(contact_types: {active: true}).uniq
  end

  def create
    # These variables are used to re-render the form (render :new) if there are
    # validation errors so that the user does not lose inputs to fields that
    # they did previously enter.
    @casa_cases = policy_scope(current_organization.casa_cases)
    @case_contact = CaseContact.new(create_case_contact_params)
    @current_organization_groups = current_organization.contact_type_groups

    @selected_cases = @casa_cases.where(id: params.dig(:case_contact, :casa_case_id))
    if @selected_cases.empty?
      flash[:alert] = "At least one case must be selected"
      render :new
      return
    end

    # Create a case contact for every case that was checked
    case_contacts = @selected_cases.map { |casa_case|
      casa_case.case_contacts.create(create_case_contact_params)
    }

    if case_contacts.all?(&:persisted?)
      redirect_to casa_case_path(CaseContact.last.casa_case), notice: "Case contact was successfully created."
    else
      @case_contact = case_contacts.first
      @casa_cases = [@case_contact.casa_case]
      render :new
    end
  end

  # GET /case_contacts/1/edit
  def edit
    @casa_cases = [@case_contact.casa_case]
    @selected_cases = @casa_cases
    @current_organization_groups = current_organization.contact_type_groups
  end

  # PATCH/PUT /case_contacts/1
  # PATCH/PUT /case_contacts/1.json
  def update
    @casa_cases = [@case_contact.casa_case]
    @selected_cases = @casa_cases
    @current_organization_groups = current_organization.contact_type_groups

    respond_to do |format|
      if @case_contact.update_cleaning_contact_types(update_case_contact_params)
        format.html { redirect_to casa_case_path(@case_contact.casa_case), notice: "Case contact was successfully updated." }
        format.json { render :show, status: :ok, location: @case_contact }
      else
        format.html { render :edit }
        format.json { render json: @case_contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /case_contacts/1
  # DELETE /case_contacts/1.json
  def destroy
    @case_contact.destroy
    respond_to do |format|
      format.html do
        redirect_to case_contacts_url, notice: "Case contact was successfully destroyed."
      end
      format.json { head :no_content }
    end
  end

  private

  def set_case_contact
    @case_contact = authorize(current_organization.case_contacts.find(params[:id]))
  end

  def set_contact_types
    @contact_types = ContactType.for_organization(current_organization)
  end

  def create_case_contact_params
    CaseContactParameters
      .new(params)
      .with_creator(current_user)
      .with_converted_duration_minutes(params[:case_contact][:duration_hours].to_i)
  end

  def update_case_contact_params
    # Updating a case contact does not change its original creator
    CaseContactParameters
      .new(params)
      .with_converted_duration_minutes(params[:case_contact][:duration_hours].to_i)
  end
end
