module CourtReportDueSmsReminderService
  extend self
  include SmsReminderService
  include SmsBodyHelper

  GENERATE_CASE_COURT_REPORT_LINK = "/case_court_reports"

  def court_report_reminder(user, report_due_date)
    short_link = create_short_link(GENERATE_CASE_COURT_REPORT_LINK)
    message = court_report_due_msg(report_due_date, short_link)
    send_reminder(user, message) # ##checks for twilio_enabled###
  end
end
