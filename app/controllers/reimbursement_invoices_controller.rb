class ReimbursementInvoicesController < ApplicationController
  def view
    reimbursement = Reimbursement.find(params[:reimbursement_id])
    authorize reimbursement
    @invoice = Invoice.new(reimbursement)
  end
end
