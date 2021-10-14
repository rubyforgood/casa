class ReimbursementsController < ApplicationController


  def new
  end
  def index
    @reimbursements = CaseContact.where(
      want_driving_reimbursement: true
    ).where("case_contacts.created_at > ?", 1.year.ago)
  end

end
