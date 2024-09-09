class CaseContacts::FormController < ApplicationController
  include Wicked::Wizard

  before_action :require_organization!
  before_action :set_case_contact, only: [:show, :update]
  after_action :verify_authorized

  steps :details

  # wizard_path
  def show
    authorize @case_contact

    get_cases_and_contact_types

    if @case_contact.started?
      @case_contact.contact_made = true
    end

    render_wizard
    wizard_path
  end

  def update
    authorize @case_contact
    params[:case_contact][:status] = CaseContact.statuses[step] if !@case_contact.active?
    remove_unwanted_contact_types
    remove_nil_draft_ids

    if @case_contact.update(case_contact_params)
      respond_to do |format|
        format.html {
          if step == steps.last
            finish_editing
          else
            render_wizard @case_contact, {}, {case_contact_id: @case_contact.id}
          end
        }
        format.json { head :ok }
      end
    else
      respond_to do |format|
        format.html {
          get_cases_and_contact_types
          render step
        }
        format.json { head :internal_server_error }
      end
    end
  end

  private

  def set_case_contact
    # ? includes additional_expenses
    # ? includes contact_topic_answers: :contact_topic
    @case_contact = CaseContact
      .includes(:creator)
      .find(params[:case_contact_id])
  end

  def get_cases_and_contact_types
    @casa_cases = policy_scope(current_organization.casa_cases).includes([:volunteers])
    # ? limiting to one case.. also disable input if this happens?
    @casa_cases = @casa_cases.where(id: @case_contact.casa_case_id) if @case_contact.active?

    @case_contact_types = ContactType.includes(:contact_type_group)
      .joins(:casa_case_contact_types)
      .active
      .where(casa_case_contact_types: {casa_case_id: @casa_cases.pluck(:id)})

    @contact_types = if @case_contact_types.present?
      @case_contact_types
    else
      ContactType
        .includes(:contact_type_group)
        .joins(:contact_type_group)
        .active
        .where(contact_type_group: {casa_org: current_organization})
        .order("contact_type_group.name ASC", :name) # template builds grouped type checkboxes
    end

    @contact_topics = ContactTopic
      .active
      .where(casa_org: current_organization)
      .order(:question)
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
      # save all draft case ids in metadata?
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
