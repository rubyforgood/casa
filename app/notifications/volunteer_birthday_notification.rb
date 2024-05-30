# To deliver this notification:
#
# VolunteerBirthdayNotification.with(post: @post).deliver_later(current_user)
# VolunteerBirthdayNotification.with(post: @post).deliver(current_user)

class VolunteerBirthdayNotification < Notification
  # deliver_by :email, mailer: "UserMailer"
  # deliver_by :slack
  # deliver_by :custom, class: "MyDeliveryMethod"

  # Add required params
  required_param :volunteer

  # Define helper methods to make rendering easier.
  def message
    "🎉 🎂  #{params[:volunteer].display_name}'s birthday is on #{params[:volunteer].decorate.formatted_birthday}!"
  end

  def title
    "Volunteer Birthday Notification"
  end

  def url
    ""
  end
end
