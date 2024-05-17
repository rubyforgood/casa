# To deliver this notification:
#
# YouthBirthdayNotifier.with(post: @post).deliver_later(current_user)
# YouthBirthdayNotifier.with(post: @post).deliver(current_user)

class YouthBirthdayNotifier < BaseNotifier
  # deliver_by :email, mailer: "UserMailer"
  # deliver_by :slack
  # deliver_by :custom, class: "MyDeliveryMethod"

  # Add required params
  #
  required_param :casa_case

  # Define helper methods to make rendering easier.

  def message
    "Your youth, case number: #{params[:casa_case].case_number} has a birthday next month."
  end

  def title
    "Youth Birthday Notification"
  end

  def url
    casa_case_path(params[:casa_case].id)
  end
end
