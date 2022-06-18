class CourtReportDueSMSReminderSerivce
  BASE_URL = Rails.application.credentials[:BASE_URL]
  GENERATE_CASE_COURT_REPORT_LINK = "/case_court_reports"

  def self.court_report_reminder(user, report_due_date)
    user_casa_org = user.casa_org
    twilio_service = TwilioService.new(user_casa_org.twilio_api_key_sid, user_casa_org.twilio_api_key_secret, user_casa_org.twilio_account_sid)
    sms_params = {
      From: user_casa_org.twilio_phone_number,
      Body: create_message(report_due_date),
      To: user.phone_number
    }
    twilio_service.send_sms(sms_params)
  end

  private

  def create_message(report_due_date)
    "Your court report is due on #{report_due_date}. Generate a court report to complete & submit here: " + create_short_link
  end

  def create_short_link
    if BASE_URL.blank?
      raise "BASE_URL environment variable not defined"
    end

    short_url_service = ShortUrlService.new
    short_url_service.create_short_link(BASE_URL + GENERATE_CASE_COURT_REPORT_LINK)
    short_url_service.short_url
  end
end