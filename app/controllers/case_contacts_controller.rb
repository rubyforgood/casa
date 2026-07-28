# frozen_string_literal: true

class CaseContactsController < ApplicationController
  include LoadsCaseContacts

  before_action :set_case_contact, only: %i[edit destroy discard_draft]
  before_action :set_contact_types, only: %i[edit]
  before_action :require_organization!
  after_action :verify_authorized, except: %i[leave]

  def index
    @active_nav = "contacts"
    load_case_contacts
    render :index, layout: "casa_app" unless performed?
  end

  def drafts
    authorize CaseContact
    @active_nav = "contacts"

    @case_contacts = current_organization.case_contacts.not_active
    render layout: "casa_app"
  end

  def edit
    authorize @case_contact
    redirect_to case_contact_form_path(:details, case_contact_id: @case_contact.id)
  end

  def destroy
    authorize @case_contact

    @case_contact.destroy

    respond_to do |format|
      format.html do
        flash[:notice] = "Contact is successfully deleted."
        redirect_to request.referer
      end
      format.json { head :no_content }
    end
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

  # Explicit "Discard draft" from the form. Separate from #destroy because the redirect differs: that
  # one returns to `request.referer`, which here is the form of the record just deleted. This returns
  # where the form was opened from (session[:return_to], set by #new), so discarding lands in the same
  # place as Back and as a successful Submit.
  def discard_draft
    authorize @case_contact

    if @case_contact.active?
      # An active contact is a real record, not a draft; deleting one goes through #destroy.
      return redirect_back_to_referer(fallback_location: case_contacts_path)
    end

    @case_contact.discard!
    flash[:notice] = "Draft discarded."
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

  def additional_expense_params
    @additional_expense_params ||= AdditionalExpenseParamsService.new(params).calculate
  end

  def set_case_contact
    @case_contact = authorize(current_organization.case_contacts.find_by(id: params[:id]))
    redirect_to authenticated_user_root_path unless @case_contact
  end
end
