class NoContactMadeReminder
  def send!
    responses = []

    eligible_volunteers = Volunteer.where(receive_sms_notifications: true)
      .where.not(phone_number: nil)
      .select { |v| !quarterly_case_contacts_type_reminder_sent_today(v) }

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
      update_reminder_sent_time(volunteer)
    end

    responses
  end

  def get_contact_types_in_past_2_weeks(volunteer, contact_made)
    volunteer.case_contacts.where("occurred_at > ?", 2.weeks.ago).where(contact_made: contact_made).joins(:contact_types).pluck(:name)
  end

  def quarterly_case_contacts_type_reminder_sent_today(volunteer)
    reminder = UserReminderTime.find_by(user_id: volunteer.id)

    if reminder&.case_contact_types
      return reminder.case_contact_types.today?
    end

    false
  end

  def update_reminder_sent_time(volunteer)
    reminder = UserReminderTime.find_by(user_id: volunteer.id)

    if reminder
      reminder.no_contact_made = DateTime.now
    else
      reminder = UserReminderTime.new(user_id: volunteer.id, no_contact_made: DateTime.now)
    end

    reminder.save
  end
end
