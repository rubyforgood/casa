# frozen_string_literal: true

class CaseContactsController < ApplicationController
  before_action :set_case_contact, only: %i[edit update destroy]
  before_action :set_contact_types, only: %i[new edit update create]
  before_action :require_organization!
  after_action :verify_authorized

  def index
    authorize CaseContact

    @current_organization_groups = current_organization_groups

    @filterrific = initialize_filterrific(
      all_case_contacts,
      params[:filterrific],
      select_options: {
        sorted_by: CaseContact.options_for_sorted_by
      }
    ) || return

    case_contacts = @filterrific.find.group_by(&:casa_case_id)

    @presenter = CaseContactPresenter.new(case_contacts)
  end

  def new
    authorize CaseContact
    @casa_cases = policy_scope(current_organization.casa_cases)

    # Select the most likely case option
    # - If there are cases defined in the params, select those cases (often coming from the case page)
    # - If there is only one case, select that case
    # - If there are no hints, let them select their case
    @selected_cases =
      if params.dig(:case_contact, :casa_case_id).present?
        @casa_cases.where(id: params.dig(:case_contact, :casa_case_id))
      elsif @casa_cases.count == 1
        @casa_cases[0, 1]
      else
        []
      end

    @case_contact = CaseContact.new

    @selected_case_contact_types = @casa_cases.flat_map(&:contact_types)

    @current_organization_groups =
      if @selected_case_contact_types.present?
        @selected_case_contact_types.map(&:contact_type_group).uniq
      else
        current_organization
          .contact_type_groups
          .joins(:contact_types)
          .where(contact_types: {active: true})
          .alphabetically
          .uniq
      end
  end

  def create
    # These variables are used to re-render the form (render :new) if there are
    # validation errors so that the user does not lose inputs to fields that
    # they did previously enter.

    @casa_cases = policy_scope(current_organization.casa_cases)
    @case_contact = CaseContact.new(create_case_contact_params.except(:casa_case_attributes))
    authorize @case_contact
    @current_organization_groups = current_organization.contact_type_groups

    @selected_cases = @casa_cases.where(id: params.dig(:case_contact, :casa_case_id))
    if @selected_cases.empty?
      flash[:alert] = "At least one case must be selected"
      render :new
      return
    end
    # Create a case contact for every case that was checked
    case_contacts = create_case_contact_for_every_selected_casa_case(@selected_cases)
    if case_contacts.any?(&:new_record?)
      @case_contact = case_contacts.first
      @casa_cases = [@case_contact.casa_case]
      render :new
    elsif @selected_cases.count > 1
      redirect_to case_contacts_path(success: true), notice: "Case contacts successfully created"
    else
      redirect_to casa_case_path(CaseContact.last.casa_case, success: true), notice: "Case contact successfully created"
    end
  end

  def edit
    authorize @case_contact
    current_user.notifications.unread.where(id: params[:notification_id]).mark_as_read!
    @casa_cases = [@case_contact.casa_case]
    @selected_cases = @casa_cases
    @current_organization_groups = current_organization.contact_type_groups
  end

  def update
    authorize @case_contact
    @casa_cases = [@case_contact.casa_case]
    @selected_cases = @casa_cases
    @current_organization_groups = current_organization.contact_type_groups

    if @case_contact.update_cleaning_contact_types(update_case_contact_params)
      if additional_expense_params&.any? && policy(:case_contact).additional_expenses_allowed?
        update_or_create_additional_expense(additional_expense_params, @case_contact)
      end
      if @case_contact.valid?
        created_at = @case_contact.created_at.strftime("%-I:%-M %p on %m-%e-%Y")
        flash[:notice] = "Case contact created at #{created_at}, was successfully updated."
        send_reimbursement_email(@case_contact)
        redirect_to casa_case_path(@case_contact.casa_case)
      else
        render :edit
      end
    else
      render :edit
    end
  end

  def destroy
    authorize CaseContact

    @case_contact.destroy
    flash[:notice] = "Contact is successfully deleted."
    redirect_to request.referer
  end

  def restore
    authorize CasaAdmin

    case_contact = authorize(current_organization.case_contacts.with_deleted.find(params[:id]))
    case_contact.restore(recursive: true)
    flash[:notice] = "Contact is successfully restored."
    redirect_to request.referer
  end

  private

  def update_or_create_additional_expense(all_ae_params, cc)
    all_ae_params.each do |ae_params|
      id = ae_params[:id]
      current = AdditionalExpense.find_by(id: id)
      if current
        current.assign_attributes(other_expense_amount: ae_params[:other_expense_amount], other_expenses_describe: ae_params[:other_expenses_describe])
        save_or_add_error(current, cc)
      else
        create_new_exp = cc.additional_expenses.build(ae_params)
        save_or_add_error(create_new_exp, cc)
      end
    end
  end

  def save_or_add_error(obj, case_contact)
    obj.valid? ? obj.save : case_contact.errors.add(:base, obj.errors.full_messages.to_sentence)
  end

  def create_case_contact_for_every_selected_casa_case(selected_cases)
    selected_cases.map do |casa_case|
      if policy(:case_contact).additional_expenses_allowed?
        new_cc = casa_case.case_contacts.new(create_case_contact_params.except(:casa_case_attributes))
        update_or_create_additional_expense(additional_expense_params, new_cc)
        if new_cc.valid?
          new_cc.save!
        else
          new_cc.errors
        end
      else
        new_cc = casa_case.case_contacts.create(create_case_contact_params.except(:casa_case_attributes))
      end

      case_contact = @case_contact.dup

      send_reimbursement_email(case_contact)

      case_contact.casa_case = casa_case
      if @selected_cases.count == 1 && case_contact.valid?
        if current_role == "Volunteer"
          update_volunteer_address
        elsif ["Supervisor", "Casa Admin"].include?(current_role) && casa_case.volunteers.count == 1
          update_volunteer_address(casa_case.volunteers[0])
        end
      end
      new_cc
    end
  end

  def send_reimbursement_email(case_contact)
    if case_contact.want_driving_reimbursement_changed? && case_contact.want_driving_reimbursement? && !current_user.supervisor.blank?
      SupervisorMailer.reimbursement_request_email(current_user, current_user.supervisor).deliver
    end
  end

  def update_volunteer_address(volunteer = current_user)
    content = create_case_contact_params.dig(:casa_case_attributes, :volunteers_attributes, "0", :address_attributes, :content)
    return if content.blank?
    if volunteer.address
      volunteer.address.update!(content: content)
    else
      volunteer.address = Address.new(content: content)
      volunteer.save!
    end
  end

  def set_case_contact
    if current_organization.case_contacts.exists?(params[:id])
      @case_contact = authorize(current_organization.case_contacts.find(params[:id]))
    else
      redirect_to authenticated_user_root_path
    end
  end

  def set_contact_types
    @contact_types = ContactType.for_organization(current_organization)
  end

  def create_case_contact_params
    CaseContactParameters.new(params, creator: current_user)
  end

  def update_case_contact_params
    # Updating a case contact should not change its original creator
    CaseContactParameters.new(params)
  end

  def current_organization_groups
    current_organization.contact_type_groups
      .includes(:contact_types)
      .joins(:contact_types)
      .where(contact_types: {active: true})
      .uniq
  end

  def all_case_contacts
    query = policy_scope(current_organization.case_contacts).includes(:creator, contact_types: :contact_type_group)
    if params[:casa_case_id].present?
      query = query.where(casa_case_id: params[:casa_case_id])
    end
    query
  end

  def additional_expense_params
    @additional_expense_params ||= AdditionalExpenseParamsService.new(params).calculate
  end
end
