# To deliver this notification:
#
# FollowupNotification.with(followup: @followup).deliver_later(current_user)
# FollowupNotification.with(followup: @followup).deliver(current_user)

class FollowupNotification < BaseNotification
  # Add your delivery methods
  #
  deliver_by :database
  # deliver_by :email, mailer: "UserMailer", if: :email_notifications?
  # deliver_by :sms, class: "DeliveryMethods::Sms", if: :sms_notifications?
  # deliver_by :slack
  # deliver_by :custom, class: "MyDeliveryMethod"

  # Add required params
  #
  param :followup, :created_by

  # Define helper methods to make rendering easier.
  #
  def message
    note = params[:followup][:note]

    note.present? ? message_with_note(note) : message_without_note
  end

  def url
    edit_case_contact_path(params[:followup][:case_contact_id], notification_id: record.id)
  end

  private

  def sms_notifications?
    recipient.receive_sms_notifications == true
  end

  def email_notifications?
    recipient.receive_email_notifications == true
  end

  def message_with_note(note)
    [
      message_heading,
      "Note: #{note}",
      "Click to see more."
    ].join("\n")
  end

  def message_without_note
    [message_heading, "Click to see more."].join(" ")
  end

  def message_heading
    "#{created_by_name} has flagged a Case Contact that needs follow up."
  end
end
