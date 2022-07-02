class NoContactMadeSmsReminderService < SmsReminderService
  NEW_CASE_CONTACT_LINK = "/case_contacts/new"

  class << self
    def no_contact_made_reminder(user, contact_type)
      send_reminder(user, create_message(contact_type))
    end

    private

    def create_message(contact_type)
      "It's been two weeks since you've tried reaching '#{contact_type}'. Try again! #{create_short_link(NEW_CASE_CONTACT_LINK)}"
    end
  end
end
