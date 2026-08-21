class CaseContacts::FormController < ApplicationController
  include Wicked::Wizard

  # The wizard renders on the casadesign (Tailwind) shell. layout applies to the HTML
  # render_wizard/render step paths; the autosave JSON responses skip it.
  layout "casa_app"

  before_action :require_organization!
  before_action :set_case_contact, only: [:show, :update]
  before_action :set_active_nav
  after_action :verify_authorized

  steps :details

  # Opening the form no longer inserts a row. It used to: CaseContactsController#new created the
  # record so the wizard had an id to autosave into, which meant every abandoned "New case contact"
  # click left a permanent empty draft. The record is now built unsaved and persisted by #create at
  # the first real save -- the first autosave (typing notes or a topic answer), the first checked
  # contact topic, or the submit itself.
  def new
    store_referring_location

    @case_contact = CaseContact.new(creator: current_user, contact_made: true,
      draft_case_ids: build_draft_case_ids(policy_scope(current_organization.casa_cases)))
    authorize @case_contact

    prepare_form
    render :details
  end

  def create
    @case_contact = CaseContact.new(creator: current_user)
    authorize @case_contact

    remove_nil_draft_ids

    respond_to do |format|
      format.json do
        # An autosave: keep the default `started` status so the lax draft validations apply, and hand
        # back where every later save must go -- the record exists now, so posting here again would
        # create a second draft.
        if @case_contact.update(case_contact_params)
          # discard_path travels with the id: the Discard control is server-rendered on `persisted?`,
          # and an autosave never re-renders the page, so without this it stayed hidden until a reload.
          render json: {
            id: @case_contact.id,
            form_action: wizard_path(steps.first, case_contact_id: @case_contact.id),
            discard_path: discard_draft_case_contact_path(@case_contact)
          }, status: :created
        else
          render json: @case_contact.errors.full_messages, status: :unprocessable_content
        end
      end
      format.html do
        # A real submit, so hold it to the step's validations exactly as #update does. A failure
        # persists nothing, which is the point: no draft for a form that was never valid.
        params[:case_contact][:status] = CaseContact.statuses[steps.first]
        if @case_contact.update(case_contact_params)
          finish_editing
        else
          prepare_form
          render :details, status: :unprocessable_content
        end
      end
    end
  end

  def show
    authorize @case_contact

    prepare_form

    render_wizard
  end

  def update
    authorize @case_contact

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
          render json: @case_contact.errors.full_messages, status: :unprocessable_content
        end
      end
    end
  end

  private

  def set_active_nav
    @active_nav = "contacts"
  end

  def set_case_contact
    @case_contact = CaseContact
      # contact_topic_answers' contact_topic too: saving the nested answers validates each
      # belongs_to :contact_topic, which is satisfied from the loaded record instead of a query
      # per answer.
      .includes(:creator, contact_topic_answers: :contact_topic)
      .find(params[:case_contact_id])
  end

  def prepare_form
    @casa_cases = get_casa_cases
    contact_types = get_contact_types.decorate
    @grouped_contact_types = group_contact_types_by_name(contact_types)
    # Resolved once for the whole form: both the checkbox list and the multi-select show a
    # "last logged" hint per contact type.
    @last_logged_at_by_contact_type = CaseContact.last_logged_at_by_contact_type(@casa_cases.map(&:id))
    @contact_topics = get_contact_topics
    # No pre-built blank answer: the Notes checklist lists every topic and creates an answer
    # only when a topic is checked (contact-topics controller). A seeded blank row would just
    # orphan a nil-topic answer.
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
      .distinct

    case_contact_types.presence || ContactType
      .includes(:contact_type_group)
      .joins(:contact_type_group)
      .active
      .where(contact_type_group: {casa_org: current_organization})
      .order("contact_type_group.name ASC", :name)
      .distinct
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
      # "Submit & add another" reopens a fresh form, taking the user off the list -- so surface a
      # link back to the case-contacts list (there's no per-contact show page) where it now appears
      flash[:notice_action] = {"label" => "View case contacts", "path" => case_contacts_path}
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
    volunteer = case_contact.volunteer
    return unless volunteer && case_contact.volunteer_address.present?

    address = volunteer.address || volunteer.build_address
    parts = case_contact.submitted_address_parts
    if parts.values.any?(&:present?)
      address.update(parts)
    else
      address.update(content: case_contact.volunteer_address)
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

  def remove_nil_draft_ids
    params[:case_contact][:draft_case_ids] -= [""] if params.dig(:case_contact, :draft_case_ids)
  end

  # Pre-select the case(s) the user arrived with, so a contact started from a case page is already
  # pointed at it. Moved here with #new.
  def build_draft_case_ids(casa_cases)
    return params[:draft_case_ids] if params[:draft_case_ids].present?
    return casa_cases.where(id: params.dig(:case_contact, :casa_case_id)).pluck(:id) if params.dig(:case_contact, :casa_case_id).present?
    return [casa_cases.first.id] if casa_cases.count == 1

    []
  end
end
