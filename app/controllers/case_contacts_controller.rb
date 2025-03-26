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

    @pagy, @filtered_case_contacts = pagy(@filterrific.find)
    case_contacts = CaseContact.case_hash_from_cases(@filtered_case_contacts)
    case_contacts = case_contacts.select { |k, _v| current_user.casa_cases.pluck(:id).include?(k) } if current_user.volunteer?
    case_contacts = case_contacts.select { |k, _v| k == params[:casa_case_id].to_i } if params[:casa_case_id].present?

    @presenter = CaseContactPresenter.new(case_contacts)
  end

  def drafts
    authorize CaseContact

    @case_contacts = current_organization.case_contacts.not_active
  end

  def new
    store_referring_location

    casa_cases = policy_scope(current_organization.casa_cases)
    draft_case_ids = build_draft_case_ids(params, casa_cases)

    @case_contact = CaseContact.create(creator: current_user, draft_case_ids: draft_case_ids, contact_made: true)
    authorize @case_contact

    if @case_contact.errors.any?
      flash[:alert] = @case_contact.errors.full_messages.join("\n")
      redirect_to request.referer
    else
      redirect_to case_contact_form_path(:details, case_contact_id: @case_contact.id)
    end
  end

  def edit
    authorize @case_contact
    redirect_to case_contact_form_path(:details, case_contact_id: @case_contact.id)
  end

  def destroy
    authorize @case_contact

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
    policy_scope(current_organization.case_contacts).preload(
      :creator,
      :followups,
      contact_types: :contact_type_group,
      contact_topic_answers: :contact_topic,
      casa_case: :volunteers
    )
  end

  def additional_expense_params
    @additional_expense_params ||= AdditionalExpenseParamsService.new(params).calculate
  end

  def set_case_contact
    @case_contact = authorize(current_organization.case_contacts.find_by(id: params[:id]))
    redirect_to authenticated_user_root_path unless @case_contact
  end

  def build_draft_case_ids(params, casa_cases)
    # Use case(s) from params if present
    return params[:draft_case_ids] if params[:draft_case_ids].present?
    return casa_cases.where(id: params.dig(:case_contact, :casa_case_id)).pluck(:id) if params.dig(:case_contact, :casa_case_id).present?
    return [casa_cases.first.id] if casa_cases.count == 1

    []
  end
end
