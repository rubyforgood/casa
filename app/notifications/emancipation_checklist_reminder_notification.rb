# To deliver this notification:
#
# EmancipationChecklistNotification.with(post: @post).deliver_later(current_user)
# EmancipationChecklistNotification.with(post: @post).deliver(current_user)

class EmancipationChecklistReminderNotification < BaseNotification
  # Add your delivery methods
  #
  deliver_by :database
  # deliver_by :email, mailer: "UserMailer"
  # deliver_by :slack
  # deliver_by :custom, class: "MyDeliveryMethod"

  # Add required params
  #
  param :casa_case

  # Define helper methods to make rendering easier.

  def message
    t(".message", case_number: params[:casa_case].case_number)
  end

  def title
    t(".title")
  end

  def url
    casa_case_emancipation_path(params[:casa_case].id)
  end
end
