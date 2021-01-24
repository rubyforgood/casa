# To deliver this notification:
#
# FollowupResolvedNotification.with(followup: @followup).deliver_later(current_user)
# FollowupResolvedNotification.with(followup: @followup).deliver(current_user)

class FollowupResolvedNotification < Noticed::Base
  # Add your delivery methods
  #
  deliver_by :database
  # deliver_by :email, mailer: "UserMailer"
  # deliver_by :slack
  # deliver_by :custom, class: "MyDeliveryMethod"

  # Add required params
  #
  param :followup, :created_by_name

  # Define helper methods to make rendering easier.
  #
  def message
    t(".message", created_by_name: params[:created_by_name])
  end

  def url
    edit_case_contact_path(params[:followup][:case_contact_id], notification_id: record.id)
  end
end
