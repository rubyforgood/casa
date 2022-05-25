module SmsNotificationEventPopulator
  SMS_NOTIFICATION_EVENTS = {
    Volunteer: ["CASA case youth has birthday"],
    Supervisor: ["Volunteer made case contact", "Volunteer edited case (case details, court order, court dates)"],
    CasaAdmin: ["New entry in reimbursement queue"]
  }.freeze

  def self.populate
    SMS_NOTIFICATION_EVENTS.each do |user_type, event_names|
      event_names.each do |event_name|
        SmsNotificationEvent.find_or_create_by!(name: event_name, user_type: user_type)
      end
    end
  end
end
