# To deliver this notification:
#
# EmancipationChecklistReminderNotifier.with(post: @post).deliver(current_user)
#
class EmancipationChecklistReminderNotifier < BaseNotifier
  # deliver_by :email do |config|
  #   config.mailer = "UserMailer"
  #   ...
  # end
  # deliver_by :slack
  # deliver_by :custom, class: "MyDeliveryMethod"

  # Add required params
  required_param :casa_case

  # Define helper methods to make rendering easier.

  def message
    casa_case = params[:casa_case]
    "Your case #{casa_case[:case_number]} is a transition aged youth. " \
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
