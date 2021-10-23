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
end
