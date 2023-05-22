class CaseContactTypesReminder
  NEW_CASE_CONTACT_PAGE_PATH = Rails.application.credentials[:BASE_URL]
  FIRST_MESSAGE = "It's been 60 days or more since you've reached out to these members of your youth's network:\n"
  THIRD_MESSAGE = "If you have made contact with them in the past 60 days, remember to log it: "

  def send!
    if NEW_CASE_CONTACT_PAGE_PATH.blank?
      raise "NEW_CASE_CONTACT_PAGE_PATH environment variable not defined"
    end
    responses = []
    eligible_volunteers = Volunteer.where(receive_sms_notifications: true)
      .where.not(phone_number: nil)
      .select { |v| !last_reminder_within_quarter(v) }

    eligible_volunteers.each do |volunteer|
      uncontacted_case_contact_type_names = uncontacted_case_contact_types(volunteer)
      if uncontacted_case_contact_type_names.count > 0
        responses.push(
          {
            volunteer: volunteer,
            messages: send_sms_messages(volunteer, uncontacted_case_contact_type_names)
          }
        )
        UserReminderTime.find_by(user_id: volunteer.id)&.update_attributes(case_contact_types: DateTime.now)
      end
    end

    responses
  end

  private

  def uncontacted_case_contact_types(volunteer)
    contacted_types = volunteer.case_contacts.where("occurred_at > ?", 2.months.ago).joins(:contact_types).pluck(:name)
    ContactType.all.pluck(:name).uniq - contacted_types
  end

  def send_sms_messages(volunteer, uncontacted_case_contact_type_names)
    volunteer_casa_org = volunteer.casa_org
    if !valid_casa_twilio_creds(volunteer_casa_org)###checks for twilio_enabled###
      return
    end
    
    twilio_service = TwilioService.new(volunteer_casa_org.twilio_api_key_sid, volunteer_casa_org.twilio_api_key_secret, volunteer_casa_org.twilio_account_sid)
    sms_params = {
      From: volunteer_casa_org.twilio_phone_number,
      Body: nil,
      To: volunteer.phone_number
    }

    messages = [
      FIRST_MESSAGE,
      uncontacted_case_contact_type_names.map { |name| "• #{name}" }.join("\n"),
      THIRD_MESSAGE + new_case_contact_page_short_link
    ]

    responses = []
    messages.each do |content|
      sms_params[:Body] = content
      responses.push(twilio_service.send_sms(sms_params))
    end

    responses
  end

  def valid_casa_twilio_creds(casa_org)
    casa_org.twilio_enabled? && casa_org.twilio_phone_number? && casa_org.twilio_account_sid? && casa_org.twilio_api_key_sid? && casa_org.twilio_api_key_secret?
  end

  def last_reminder_within_quarter(volunteer)
    reminder = UserReminderTime.find_by(user_id: volunteer.id)

    if reminder&.case_contact_types
      return reminder.case_contact_types > 3.months.ago
    end

    false
  end

  def new_case_contact_page_short_link
    short_url_service = ShortUrlService.new
    short_url_service.create_short_url(NEW_CASE_CONTACT_PAGE_PATH + "/case_contacts/new")
    short_url_service.short_url
  end
end
