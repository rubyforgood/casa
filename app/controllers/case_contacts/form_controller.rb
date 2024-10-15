class CaseContacts::FormController < ApplicationController
  include Wicked::Wizard

  before_action :require_organization!
  before_action :set_case_contact, only: [:show, :update]
  after_action :verify_authorized

  steps :details

  def show
    authorize @case_contact

    prepare_form

    if @case_contact.started? && @case_contact.contact_topic_answers.empty?
      @case_contact.contact_topic_answers.build()
    end

    render_wizard
  end

  def update
    authorize @case_contact

    remove_unwanted_contact_types
    remove_nil_draft_ids

    respond_to do |format|
      format.html do
        params[:case_contact][:status] = CaseContact.statuses[step] if !@case_contact.active?
        if @case_contact.update(case_contact_params)
          finish_editing
        else
          prepare_form
          render step
        end
      end
      format.json do
        if @case_contact.update(case_contact_params)
          render json: @case_contact, status: :ok
        else
          render json: @case_contact.errors.full_messages, status: :unprocessable_entity
        end
      end
    end
  end

  private

  def set_case_contact
    @case_contact = CaseContact
      .includes(:creator, :contact_topic_answers)
      .find(params[:case_contact_id])
  end

  def prepare_form
    @casa_cases = get_casa_cases
    contact_types = get_contact_types.decorate
    @grouped_contact_types = group_contact_types_by_name(contact_types)
    @contact_topics = get_contact_topics
  end

  def get_casa_cases
    casa_cases = policy_scope(current_organization.casa_cases).includes([:volunteers])
    casa_cases = casa_cases.where(id: @case_contact.casa_case_id) if @case_contact.active?
    casa_cases
  end

  def get_contact_types
    case_contact_types = ContactType.includes(:contact_type_group)
      .joins(:casa_case_contact_types)
      .active
      .where(casa_case_contact_types: {casa_case_id: @casa_cases.pluck(:id)})

    if case_contact_types.present?
      case_contact_types
    else
      ContactType
        .includes(:contact_type_group)
        .joins(:contact_type_group)
        .active
        .where(contact_type_group: {casa_org: current_organization})
        .order("contact_type_group.name ASC", :name)
    end
  end

  def get_contact_topics
    ContactTopic
      .active
      .where(casa_org: current_organization)
      .order(:question)
  end

  def group_contact_types_by_name(contact_types)
    contact_types.group_by { |ct| ct.contact_type_group.name }
  end

  def finish_editing
    message = ""
    send_reimbursement_email(@case_contact)
    draft_case_ids = @case_contact.draft_case_ids
    if @case_contact.active?
      message = @case_contact.decorate.form_updated_message
    else
      message = "Case #{"contact".pluralize(draft_case_ids.count)} successfully created."
      create_additional_case_contacts(@case_contact)
      first_casa_case_id = draft_case_ids.first
      @case_contact.update(status: "active", draft_case_ids: [first_casa_case_id], casa_case_id: first_casa_case_id)
    end
    update_volunteer_address(@case_contact)
    flash[:notice] = message
    if @case_contact.metadata["create_another"]
      redirect_to new_case_contact_path(params: {draft_case_ids:, ignore_referer: true})
    else
      redirect_back_to_referer(fallback_location: case_contacts_path(success: true))
    end
  end

  def send_reimbursement_email(case_contact)
    if case_contact.should_send_reimbursement_email?
      SupervisorMailer.reimbursement_request_email(case_contact.creator, case_contact.supervisor).deliver_later
    end
  end

  def update_volunteer_address(case_contact)
    return unless case_contact.volunteer_address.present? && !case_contact.address_field_disabled?

    address = case_contact.volunteer.address || case_contact.volunteer.build_address
    address.update(content: case_contact.volunteer_address)
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
      case_contact.case_contact_contact_types.each do |ccct|
        new_case_contact.case_contact_contact_types.new(contact_type_id: ccct.contact_type_id)
      end
      case_contact.additional_expenses.each do |ae|
        new_case_contact.additional_expenses.new(
          other_expense_amount: ae.other_expense_amount,
          other_expenses_describe: ae.other_expenses_describe
        )
      end
      case_contact.contact_topic_answers.each do |cta|
        new_case_contact.contact_topic_answers << cta.dup
      end

      new_case_contact.save!
    end
  end

  def case_contact_params
    CaseContactParameters.new(params)
  end

  # Deletes the current associations (from the join table) only if the submitted form body has the parameters for
  # the contact_type ids.
  def remove_unwanted_contact_types
    @case_contact.contact_types.clear if params.dig(:case_contact, :contact_type_ids)
  end

  def remove_nil_draft_ids
    params[:case_contact][:draft_case_ids] -= [""] if params.dig(:case_contact, :draft_case_ids)
  end
end
