class ReimbursementsController < ApplicationController
  def new
  end

  def index
    authorize :reimbursement

    @complete_status = params[:status] == "complete"
    @datatable_url = datatable_reimbursements_path(format: :json, status: params[:status])
    @reimbursements = fetch_reimbursements_for_list(@complete_status)
    @grouped_reimbursements = @reimbursements.group_by { |cc| "#{cc.occurred_at}-#{cc.creator_id}" }
  end

  def datatable
    authorize :reimbursement

    @complete_status = params[:status] == "complete"
    reimbursements = fetch_reimbursements_for_list(@complete_status)
    datatable = ReimbursementDatatable.new reimbursements, params

    render json: datatable
  end

  def change_complete_status
    authorize :reimbursement

    @case_contact = fetch_reimbursements.find(params[:reimbursement_id])
    @grouped_case_contacts = fetch_reimbursements
      .where({occurred_at: @case_contact.occurred_at, creator_id: @case_contact.creator_id})
    @grouped_case_contacts.update_all(reimbursement_params.to_h)
    redirect_to reimbursements_path unless params[:ajax]
  end

  private

  def reimbursement_params
    params.require(:case_contact).permit(:reimbursement_complete, :reimbursement_id)
  end

  def fetch_reimbursements
    case_contacts = CaseContact.joins(:casa_case).includes(
      :creator,
      :case_contact_contact_type,
      contact_types: [:contact_type_group]
    ).preload(:casa_case)
    policy_scope(case_contacts, policy_scope_class: ReimbursementPolicy::Scope)
  end

  def fetch_reimbursements_for_list(complete_only)
    fetch_reimbursements
      .want_driving_reimbursement(true)
      .created_max_ago(1.year.ago)
      .filter_by_reimbursement_status(complete_only)
  end
end
