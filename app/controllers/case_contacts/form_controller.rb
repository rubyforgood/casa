class CaseContacts::FormController < ApplicationController
  include Wicked::Wizard

  before_action :set_progress
  before_action :require_organization!
  after_action :verify_authorized

  steps(*CaseContact::FORM_STEPS)

  # wizard_path
  def show
    @case_contact = CaseContact.find(params[:case_contact_id])
    authorize @case_contact
    get_cases_and_contact_types
    @page = wizard_steps.index(step) + 1
    @total_pages = steps.count

    render_wizard
    wizard_path
  end

  def update
    @case_contact = CaseContact.find(params[:case_contact_id])
    authorize @case_contact
    if @case_contact.active?
      # do nothing
    else
      begin
      params[:case_contact] ||= []
      params[:case_contact][:status] = step.to_s # TODO: where is this used?? what is it for??
      rescue => e
        # TODO https://app.bugsnag.com/ruby-for-good/casa/errors/6637007c6857010008cfc9dd
        Bugsnag.notify(e)
      end
    end

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

  def get_cases_and_contact_types
    @casa_cases = policy_scope(current_organization.casa_cases)
    @casa_cases = @casa_cases.where(id: @case_contact.casa_case_id) if @case_contact.active?

    @selected_case_contact_types = @casa_cases.flat_map(&:contact_types)

    @current_organization_groups =
      if @selected_case_contact_types.present?
        @selected_case_contact_types.map(&:contact_type_group).uniq
      else
        current_organization.contact_types_by_group
      end
  end

  def finish_editing
    message = ""
    send_reimbursement_email(@case_contact)
    if @case_contact.active?
      message = @case_contact.decorate.form_updated_message
    else
      message = "Case #{"contact".pluralize(@case_contact.draft_case_ids.count)} successfully created."
      create_additional_case_contacts(@case_contact)
      first_casa_case_id = @case_contact.draft_case_ids.slice(0)
      @case_contact.update(status: "active", draft_case_ids: [first_casa_case_id], casa_case_id: first_casa_case_id)
    end
    update_volunteer_address(@case_contact)
    flash[:notice] = message
    redirect_back_to_referer(fallback_location: case_contacts_path(success: true))
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
      case_contact.case_contact_contact_type.each do |ccct|
        new_case_contact.case_contact_contact_type.new(contact_type_id: ccct.contact_type_id)
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
    if params.dig(:case_contact, :case_contact_contact_type_attributes)
      @case_contact.case_contact_contact_type.destroy_all
    end
  end

  def remove_nil_draft_ids
    if params.dig(:case_contact, :draft_case_ids)
      params[:case_contact][:draft_case_ids] -= [""]
    end
  end

  def set_progress
    @progress = if wizard_steps.any? && wizard_steps.index(step).present?
      ((wizard_steps.index(step) + 1).to_d / wizard_steps.count.to_d) * 100
    else
      0
    end
  end
end
