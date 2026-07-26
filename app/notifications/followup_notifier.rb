# To deliver this notification:
#
# FollowupNotifier.with(followup: @followup).deliver(current_user)
#
class FollowupNotifier < BaseNotifier
  deliver_by :email do |config|
    config.mailer = "UserMailer"
    config.method = "followup_notification"
    config.args = -> { [recipient, params[:followup]] }
    config.if = -> { recipient.receive_email_notifications? }
  end

  # deliver_by :email do |config|
  #   config.mailer = "UserMailer"
  #   ...
  # end
  # deliver_by :sms, class: "DeliveryMethods::Sms", if: :sms_notifications?
  # deliver_by :slack
  # deliver_by :custom, class: "MyDeliveryMethod"

  # Add required params
  required_params :followup, :created_by

  # Define helper methods to make rendering easier.
  def title
    "New followup"
  end

  def message
    build_message
  end

  def url
    followup = params[:followup]
    followup ? edit_case_contact_path(followup.case_contact_id) : case_contacts_path
  end

  private

  def sms_notifications?
    recipient.receive_sms_notifications == true
  end

  def email_notifications?
    recipient.receive_email_notifications == true
  end

  def build_message
    # params[:followup] can be nil if the followup (or its case contact) was deleted after the
    # notification was sent -- the GlobalID no longer resolves. Degrade gracefully instead of crashing
    # the whole notifications page.
    note = params[:followup]&.note
    join_char = note.present? ? "\n" : " "
    result = ["#{created_by} has flagged a Case Contact that needs follow up."]
    result << "Note: #{note}" if note.present?
    result << "Click to see more."
    result.join(join_char)
  end
end
