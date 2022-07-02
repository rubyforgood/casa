class NoContactMadeReminder
  def send!
    responses = []

    eligible_volunteers = Volunteer.where(receive_sms_notifications: true)
      .where.not(phone_number: nil)
      .select { |v| !quarterly_case_contacts_type_reminder_sent_today(v) }

    eligible_volunteers.each do |volunteer|
      contact_types = contact_types_to_contact(volunteer)
      if contact_types.count > 0
        responses += send_reminders(volunteer, contact_types)
      end
    end

    responses
  end

  private

  def send_reminders(volunteer, contact_types)
    responses = []
    contact_types.each do |type|
      responses.push(
        {
          volunteer: volunteer,
          messages: NoContactMadeReminderService.no_contact_made_reminder(volunteer, type)
        }
      )
      update_reminder_sent_time(volunteer)
    end
    responses
  end

  def contact_types_to_contact(volunteer)
    
  end

  def quarterly_case_contacts_type_reminder_sent_today(volunteer)
    reminder = UserCaseContactTypesReminder.find_by(user_id: volunteer.id)

    if reminder
      return reminder.reminder_sent.today?
    
    false
  end

  def update_reminder_sent_time(volunteer)
    reminder = UserNoContactMadeReminder.find_by(user_id: volunteer.id)

    if reminder
      reminder.reminder_sent = DateTime.now
    else
      reminder = UserNoContactMadeReminder.new(user_id: volunteer.id, reminder_sent: DateTime.now)
    end

    reminder.save
  end
end