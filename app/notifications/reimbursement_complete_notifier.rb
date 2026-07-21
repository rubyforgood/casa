# To deliver this notification:
#
# ReimbursementCompleteNotifier.with(case_contact: @case_contact).deliver(current_user)
#
class ReimbursementCompleteNotifier < BaseNotifier
  # This notifier is delivered to both the volunteer who submitted the
  # reimbursement and their supervisor (see ReimbursementsController#change_complete_status).
  # The email delivery is scoped to volunteer recipients only, since the
  # supervisor already knows they just marked it complete.
  deliver_by :email do |config|
    config.mailer = "VolunteerMailer"
    config.method = "reimbursement_complete_email"
    config.args = -> { [recipient, params[:case_contact]] }
    config.if = -> { recipient.volunteer? && recipient.receive_email_notifications? }
  end

  required_param :case_contact

  def title
    "Reimbursement Approved"
  end

  def message
    msg = "Volunteer #{case_contact.creator.display_name}'s request for reimbursement for #{case_contact.miles_driven}mi "
    msg += " for $#{reimbursement_amount} " if reimbursement_amount
    msg += "on #{case_contact.occurred_at_display} has been processed and is en route."
    msg
  end

  def url
    case_contacts_path(casa_case_id: case_contact.casa_case_id)
  end

  private

  def reimbursement_amount
    return @reimbursement_amount if defined?(@reimbursement_amount)

    @reimbursement_amount = case_contact.reimbursement_amount
  end

  def case_contact
    params[:case_contact]
  end
end
