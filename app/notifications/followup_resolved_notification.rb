# To deliver this notification:
#
# FollowupResolvedNotification.with(followup: @followup).deliver_later(current_user)
# FollowupResolvedNotification.with(followup: @followup).deliver(current_user)

class FollowupResolvedNotification < Notification
  # deliver_by :email, mailer: "UserMailer"
  # deliver_by :slack
  # deliver_by :custom, class: "MyDeliveryMethod"

  # Add required params
  #
  required_param :followup, :created_by

  # Define helper methods to make rendering easier.
  #
  def title
    "Followup resolved"
  end

  def message
    "#{created_by_name} resolved a follow up. Click to see more."
  end

  def url
    edit_case_contact_path(params[:followup][:case_contact_id], notification_id: self.id)
  end
end
