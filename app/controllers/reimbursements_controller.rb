class ReimbursementsController < ApplicationController
  def new
  end

  def index
    authorize :reimbursement

    @complete_status = params[:status] == "complete"

    @reimbursements = fetch_reimbursements
      .want_driving_reimbursement(true)
      .created_max_ago(1.year.ago)
      .filter_by_reimbursement_status(@complete_status)
  end

  def datatable
    authorize :reimbursement

    reimbursements = fetch_reimbursements
    datatable = ReimbursementDatatable.new reimbursements, params

    render json: datatable
  end

  def change_complete_status
    authorize :reimbursement

    @case_contact = fetch_reimbursements.find(params[:reimbursement_id])
    @case_contact.update(reimbursement_params)
    @case_contact.save!(validate: false)
    redirect_to reimbursements_path
  end

  private

  def reimbursement_params
    params.require(:case_contact).permit(:reimbursement_complete, :reimbursement_id)
  end

  def fetch_reimbursements
    policy_scope(CaseContact.joins(:casa_case), policy_scope_class: ReimbursementPolicy::Scope)
  end
end
