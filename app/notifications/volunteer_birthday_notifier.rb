# To deliver this notification:
#
# VolunteerBirthdayNotifier.with(post: @post).deliver(current_user)
#
class VolunteerBirthdayNotifier < BaseNotifier
  # deliver_by :email do |config|
  #   config.mailer = "UserMailer"
  #   ...
  # end
  # deliver_by :sms, class: "DeliveryMethods::Sms", if: :sms_notifications?
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
