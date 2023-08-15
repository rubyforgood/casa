class ReimbursementCompleteNotification < BaseNotification
  deliver_by :database

  param :case_contact

  def title
    "Reimbursement Approved"
  end

  def message
    case_contact = params[:case_contact]
    # Questions about logic for payment rate
    "Volunteer #{case_contact.creator.display_name}'s request for reimbursement for #{case_contact.miles_driven}mi on #{case_contact.occurred_at_display} has been processed and is en route."
  end

  def url
    case_contacts_path(casa_case_id: params[:case_contact].casa_case_id)
  end
end
