# frozen_string_literal: true

class CaseContactsController < ApplicationController
  include Wicked::Wizard

  before_action :set_contact_types, only: %i[new edit update create]
  before_action :require_organization!
  after_action :verify_authorized
  before_action :set_progress, only: %i[show update]

  steps :base_info, :details, :travel, :notes

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
    @drafts_count = case_contact_drafts.count

    @presenter = CaseContactPresenter.new(case_contacts)
  end

  def drafts
    authorize CaseContact

    @case_contacts = case_contact_drafts
  end

  # wizard_path
  def show
    @case_contact = CaseContact.find(params[:case_contact_id])
    authorize @case_contact
    get_cases_and_contact_types

    render_wizard
  end

  def new
    store_referring_location
    authorize CaseContact

    # - If there are cases defined in the params, select those cases (often coming from the case page)
    # - If there is only one case, select that case
    # - If there are no hints, let them select their case
    casa_cases = policy_scope(current_organization.casa_cases)
    draft_case_ids =
      if params.dig(:case_contact, :casa_case_id).present?
        casa_cases.where(id: params.dig(:case_contact, :casa_case_id)).pluck(:id)
      elsif casa_cases.count == 1
        casa_cases.first.id
      else
        []
      end

    @case_contact = CaseContact.create!(creator: current_user, draft_case_ids: draft_case_ids)
    redirect_to wizard_path(steps.first, case_contact_id: @case_contact.id)
  end

  def edit
    authorize @case_contact
    current_user.notifications.unread.where(id: params[:notification_id]).mark_as_read!
    @casa_cases = [@case_contact.casa_case]
    @selected_cases = @casa_cases
    @current_organization_groups = current_organization.contact_type_groups
  end

  def update
    @case_contact = CaseContact.find(params[:case_contact_id])
    authorize @case_contact
    params[:case_contact][:status] = step.to_s unless @case_contact.active?
    remove_unwanted_contact_types
    if @case_contact.update(case_contact_params)
      if params[:complete]
        finish_editing
      end
      render_wizard @case_contact, {}, { case_contact_id: @case_contact.id } if step != steps.last
    else
      get_cases_and_contact_types
      render step
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

  def get_cases_and_contact_types
    @casa_cases = policy_scope(current_organization.casa_cases)
    @casa_cases = @casa_cases.where(id: @case_contact.casa_case_id) if @case_contact.active?

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

  def finish_editing
    message = ""
    if @case_contact.active?
      message = "Case contact successfully updated"
    else
      message = "Case #{"contact".pluralize(@case_contact.draft_case_ids.count)} successfully created"
      create_additional_case_contacts(@case_contact)
      first_casa_case_id = @case_contact.draft_case_ids.slice(0)
      @case_contact.update!(status: "active", draft_case_ids: [first_casa_case_id], casa_case_id: first_casa_case_id)
    end
    update_volunteer_address(@case_contact.creator, @case_contact.volunteer_address)
    send_reimbursement_email(@case_contact)
    flash[:notice] = message
    redirect_back_to_referer(fallback_location: case_contacts_path(success: true))
  end

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

  # Makes a copy of the draft for all selected cases not including the first one. The draft becomes the contact for
  # the first case.
  #
  # Duplication does not duplicate associated records, so if other associations are made in the form, they need to be
  # added here, explicitly (ie. case_contact_contact_type, additional_expenses). Alternatively, could look at a gem
  # that does deep associations.
  def create_additional_case_contacts(case_contact)
    case_contact.draft_case_ids.drop(1).each do |casa_case_id|
      new_case_contact = case_contact.dup
      new_case_contact.status = "active"
      new_case_contact.draft_case_ids = [casa_case_id]
      new_case_contact.casa_case_id = casa_case_id
      case_contact.case_contact_contact_type.each do |ccct|
        new_case_contact.case_contact_contact_type.new(contact_type_id: ccct.contact_type_id)
      end
      case_contact.additional_expenses.each do |ae|
        new_case_contact.additional_expenses.new(
          other_expense_amount: ae.other_expense_amount,
          other_expenses_describe: ae.other_expenses_describe
        )
      end
      new_case_contact.save!
    end
  end

  def send_reimbursement_email(case_contact)
    if case_contact.should_send_reimbursement_email?
      SupervisorMailer.reimbursement_request_email(case_contact.creator, case_contact.supervisor).deliver_later
    end
  end

  def update_volunteer_address(volunteer, address)
    return unless address

    if volunteer.address
      volunteer.address.update(content: address)
    else
      volunteer.address = Address.new(content: address)
      volunteer.save!
    end
  end

  def set_contact_types
    @contact_types = ContactType.for_organization(current_organization)
  end

  def case_contact_params
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

  # Deletes the current associations (from the join table) only if the submitted form body has the parameters for
  # the contact_type ids.
  def remove_unwanted_contact_types
    if params.dig(:case_contact, :case_contact_contact_type_attributes)
      @case_contact.case_contact_contact_type.destroy_all
    end
  end

  def set_progress
    @progress = if wizard_steps.any? && wizard_steps.index(step).present?
      ((wizard_steps.index(step) + 1).to_d / wizard_steps.count.to_d) * 100
    else
      0
    end
  end

  def case_contact_drafts
    CaseContact.where(creator: current_user).where.not(status: "active")
  end
end
