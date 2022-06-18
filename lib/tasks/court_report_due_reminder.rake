desc "Send an email to volunteers when their court report is due in 1 week, run by heroku scheduler."
task court_report_due_reminder: :environment do
  Volunteer.send_court_report_reminder
end
