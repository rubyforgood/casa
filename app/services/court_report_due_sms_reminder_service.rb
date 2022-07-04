class CourtReportDueSmsReminderService < SmsReminderService
  GENERATE_CASE_COURT_REPORT_LINK = "/case_court_reports"

  class << self
    include SmsBodyHelper

    def court_report_reminder(user, report_due_date)
      short_link = create_short_link(GENERATE_CASE_COURT_REPORT_LINK)
      message = court_report_due_msg(report_due_date, short_link)
      send_reminder(user, message)
    end
  end
end
