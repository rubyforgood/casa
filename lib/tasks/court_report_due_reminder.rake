desc "Send an email to volunteers when their court report is due in 1 week, run by heroku scheduler."
task court_report_due_reminder: :environment do
  Volunteer.where(active: true).where.not(case_assignments:nil).find_each do |volunteer|
    volunteer.case_assignments.each do |case_assignment|
      current_case = case_assignment.casa_case
      if (current_case.court_report_due_date == Date.today + 7.days)  && !current_case.court_report_submitted
        report_due_date = current_case.court_report_due_date
        VolunteerMailer.court_report_reminder(volunteer, report_due_date)
      end
    end
  end
end
