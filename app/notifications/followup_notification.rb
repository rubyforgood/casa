# To deliver this notification:
#
# FollowupNotification.with(followup: @followup).deliver_later(current_user)
# FollowupNotification.with(followup: @followup).deliver(current_user)

class FollowupNotification < BaseNotification
  # deliver_by :email, mailer: "UserMailer", if: :email_notifications?
  # deliver_by :sms, class: "DeliveryMethods::Sms", if: :sms_notifications?
  # deliver_by :slack
  # deliver_by :custom, class: "MyDeliveryMethod"

  # Add required params
  #
  required_param :followup, :created_by

  # Define helper methods to make rendering easier.
  #
  def title
    "New followup"
  end

  def message
    build_message
  end

  def url
    if params[:followup][:id].present?
      edit_case_contact_path(params[:followup][:id], notification_id: self.id)
    else
      root_path
    end
  end

  private

  def sms_notifications?
    recipient.receive_sms_notifications == true
  end

  def email_notifications?
    recipient.receive_email_notifications == true
  end

  def build_message
    note = params[:followup][:note]
    join_char = note.present? ? "\n" : " "
    result = ["#{created_by} has flagged a Case Contact that needs follow up."]
    result << "Note: #{note}" if note.present?
    result << "Click to see more."
    result.join(join_char)
  end
end
