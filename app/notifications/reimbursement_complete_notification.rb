class ReimbursementCompleteNotification < Notification
  required_param :case_contact

  def title
    "Reimbursement Approved"
  end

  def message
    case_contact = params[:case_contact]
    msg = "Volunteer #{case_contact.creator.display_name}'s request for reimbursement for #{case_contact.miles_driven}mi "
    msg += " for $#{case_contact.reimbursement_amount} " if case_contact.reimbursement_amount
    msg += "on #{case_contact.occurred_at_display} has been processed and is en route."
    msg
  end

  def url
    case_contacts_path(casa_case_id: params[:case_contact][:casa_case_id])
  end
end
