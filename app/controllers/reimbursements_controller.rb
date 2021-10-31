class ReimbursementsController < ApplicationController
  def new
  end

  def index
    @complete_status = params[:status] == "complete"
    @reimbursements =
      CaseContact
        .want_driving_reimbursement(true)
        .created_max_ago(1.year.ago)
        .filter_by_reimbursement_status(@complete_status)
  end

  def change_complete_status
    @case_contact = CaseContact.find(params[:reimbursement_id])
    @case_contact.update(reimbursement_params)
    @case_contact.save!(validate: false)
    redirect_to reimbursements_path
  end

  def reimbursement_params
    params.require(:case_contact).permit(:reimbursement_complete, :reimbursement_id)
  end
end
