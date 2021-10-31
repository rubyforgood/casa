class ReimbursementsController < ApplicationController
  def new
  end

  def index
    @status = params[:status] == "complete"
    @reimbursements =
      CaseContact
        .want_driving_reimbursement(true)
        .created_max_ago(1.year.ago)
        .filter_by_reimbursement_status(@status)
  end

  def mark_as_complete
    @case_contact = CaseContact.find(params[:reimbursement_id])
    @case_contact.update!(reimbursement_params)
    redirect_to reimbursements_path
  end

  def reimbursement_params
    params.require(:case_contact).permit(:reimbursement_complete, :reimbursement_id)
  end
end
