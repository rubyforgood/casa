# frozen_string_literal: true

class CaseContactsController < ApplicationController
  before_action :set_case_contact, only: %i[edit destroy]
  before_action :set_contact_types, only: %i[new edit create]
  before_action :require_organization!
  after_action :verify_authorized, except: %i[leave]

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

    case_contacts = CaseContact.case_hash_from_cases(@filterrific.find)
    case_contacts = case_contacts.select { |k, _v| k == params[:casa_case_id].to_i } if params[:casa_case_id].present?

    @presenter = CaseContactPresenter.new(case_contacts)
  end

  def drafts
    authorize CaseContact

    @case_contacts = case_contact_drafts
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
        [casa_cases.first.id]
      else
        []
      end

    @case_contact = CaseContact.create_with_answers(current_organization,
      creator: current_user, draft_case_ids: draft_case_ids)

    if @case_contact.errors.any?
      flash[:alert] = @case_contact.errors.full_messages.join("\n")
      redirect_to request.referer
    else
      redirect_to case_contact_form_path(@case_contact.form_steps.first, case_contact_id: @case_contact.id)
    end
  end

  def edit
    authorize @case_contact
    current_user.notifications.unread.where(id: params[:notification_id]).mark_as_read!
    redirect_to case_contact_form_path(@case_contact.form_steps.first, case_contact_id: @case_contact.id)
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

  def leave
    redirect_back_to_referer(fallback_location: case_contacts_path)
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

  def set_contact_types
    @contact_types = ContactType.for_organization(current_organization)
  end

  def current_organization_groups
    current_organization.contact_type_groups
      .includes(:contact_types)
      .joins(:contact_types)
      .where(contact_types: {active: true})
      .uniq
  end

  def all_case_contacts
    policy_scope(current_organization.case_contacts).includes(:creator, contact_types: :contact_type_group)
  end

  def additional_expense_params
    @additional_expense_params ||= AdditionalExpenseParamsService.new(params).calculate
  end

  def case_contact_drafts
    CaseContact.where(creator: current_user).where.not(status: "active")
  end

  def set_case_contact
    if current_organization.case_contacts.exists?(params[:id])
      @case_contact = authorize(current_organization.case_contacts.find(params[:id]))
    else
      redirect_to authenticated_user_root_path
    end
  end
end
