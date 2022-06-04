# To deliver this notification:
#
# YouthBirthdayNotification.with(post: @post).deliver_later(current_user)
# YouthBirthdayNotification.with(post: @post).deliver(current_user)

class YouthBirthdayNotification < Noticed::Base
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
    t(".message", case_number: params[:case_assignment].case_number)
  end

  def title
    t(".title")
  end

  def url
    casa_case_path(params[:case_assignment].id)
  end
end
