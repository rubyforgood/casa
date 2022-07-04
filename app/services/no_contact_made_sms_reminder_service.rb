class NoContactMadeSmsReminderService < SmsReminderService
  NEW_CASE_CONTACT_LINK = "/case_contacts/new"

  class << self
    include SmsBodyHelper

    def no_contact_made_reminder(user, contact_type)
      short_link = create_short_link(NEW_CASE_CONTACT_LINK)
      message = no_contact_made_msg(contact_type, short_link)
      send_reminder(user, message)
    end
  end
end
