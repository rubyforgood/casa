# To deliver this notification:
#
# FollowupResolvedNotifier.with(followup: @followup).deliver(current_user)
#
class FollowupResolvedNotifier < BaseNotifier
  # deliver_by :email do |config|
  #   config.mailer = "UserMailer"
  #   ...
  # end
  # deliver_by :slack
  # deliver_by :custom, class: "MyDeliveryMethod"

  # Add required params
  required_params :followup, :created_by

  # Define helper methods to make rendering easier.
  #
  def title
    "Followup resolved"
  end

  def message
    "#{created_by_name} resolved a follow up. Click to see more."
  end

  def url
    polymorphic_path([:edit, followup.followupable, notification_id: id])
  end
end
