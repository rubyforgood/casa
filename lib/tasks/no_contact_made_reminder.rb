class NoContactMadeReminder
  def send!
    responses = []

    eligible_volunteers = Volunteer.where(receive_sms_notifications: true)
      .where.not(phone_number: nil)
      .select { |v| valid_past_reminders(v) }

    eligible_volunteers.each do |volunteer|
      responses += send_reminders(volunteer)
    end

    responses
  end

  private

  def send_reminders(volunteer)
    responses = []
    contact_types = get_contact_types_in_past_2_weeks(volunteer, false) - get_contact_types_in_past_2_weeks(volunteer, true)
    return responses unless contact_types.count > 0

    contact_types.each do |type|
      responses.push(
        {
          volunteer: volunteer,
          message: NoContactMadeSmsReminderService.no_contact_made_reminder(volunteer, type)
        }
      )
      UserReminderTime.find_by(user_id: volunteer.id)&.update_attributes(no_contact_made: DateTime.now)
    end

    responses
  end

  def get_contact_types_in_past_2_weeks(volunteer, contact_made)
    volunteer.case_contacts.where("occurred_at > ?", 2.weeks.ago).where(contact_made: contact_made).joins(:contact_types).pluck(:name)
  end

  def valid_past_reminders(volunteer)
    reminder = UserReminderTime.find_by(user_id: volunteer.id)

    if reminder&.case_contact_types && reminder.case_contact_types.today?
      return false
    end

    if reminder&.no_contact_made && reminder.no_contact_made >= 1.months.ago
      return false
    end

    true
  end
end
