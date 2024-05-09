# To deliver this notification:
#
# EmancipationChecklistNotification.with(post: @post).deliver_later(current_user)
# EmancipationChecklistNotification.with(post: @post).deliver(current_user)

class EmancipationChecklistReminderNotifier < Noticed::Event
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
    casa_case = params[:casa_case]
    "Your case #{casa_case.case_number} is a transition aged youth. " \
      "We want to make sure that along the way, we’re preparing our youth for emancipation. " \
      "Make sure to check the emancipation checklist."
  end

  def title
    "Emancipation Checklist Reminder"
  end

  def url
    casa_case_emancipation_path(params[:casa_case].id)
  end
end
