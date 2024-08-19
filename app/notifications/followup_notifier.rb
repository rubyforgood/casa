# To deliver this notification:
#
# FollowupNotifier.with(followup: @followup).deliver(current_user)
#
class FollowupNotifier < BaseNotifier
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
    edit_polymorphic_path(params[:followup].followupable)
  end

  private

  def sms_notifications?
    recipient.receive_sms_notifications == true
  end

  def email_notifications?
    recipient.receive_email_notifications == true
  end

  def build_message
    followup = params[:followup]
    humanized_followupable_type = followup.followupable_type.underscore.humanize.titleize
    note = followup.note
    join_char = note.present? ? "\n" : " "
    result = ["#{created_by} has flagged a #{humanized_followupable_type} that needs follow up."]
    result << "Note: #{note}" if note.present?
    result << "Click to see more."
    result.join(join_char)
  end
end
