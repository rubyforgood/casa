class CourtReportDueSmsReminderService < SmsReminderService
  GENERATE_CASE_COURT_REPORT_LINK = "/case_court_reports"

  class << self
    def court_report_reminder(user, report_due_date)
      send_reminder(user, create_message(report_due_date))
    end

    private

    def create_message(report_due_date)
      "Your court report is due on #{report_due_date}. Generate a court report to complete & submit here: " + create_short_link(GENERATE_CASE_COURT_REPORT_LINK)
    end
  end
end
