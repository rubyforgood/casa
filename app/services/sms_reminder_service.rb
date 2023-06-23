module SmsReminderService
  extend self

  BASE_URL = Rails.application.credentials[:BASE_URL]
  def send_reminder(user, message)
    return if !user[:receive_sms_notifications] || user[:phone_number].blank? || !user.casa_org.twilio_enabled?

    user_casa_org = user.casa_org
    twilio_service = TwilioService.new(user_casa_org)
    sms_params = {
      From: user_casa_org.twilio_phone_number,
      Body: message,
      To: user.phone_number
    }
    twilio_service.send_sms(sms_params)
  end

  def create_short_link(path)
    if BASE_URL.blank?
      raise "BASE_URL environment variable not defined"
    end

    short_url_service = ShortUrlService.new
    short_url_service.create_short_url(BASE_URL + path)
    short_url_service.short_url
  end
end
