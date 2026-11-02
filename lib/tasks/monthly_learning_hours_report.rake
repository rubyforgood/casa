desc "Send learning hours report to all Casa Admins and Supervisors; run daily in Heroku Scheduler, only acts on the 1st"
task send_learning_hour_reports: :environment do
  next unless Date.current.day == 1 || ENV["FORCE"] == "true"

  admins = CasaAdmin.active.where(monthly_learning_hours_report: true)
  supervisors = Supervisor.active.where(monthly_learning_hours_report: true)

  admins.each do |admin|
    LearningHoursMailer.learning_hours_report_email(admin).deliver_later
  end

  supervisors.each do |supervisor|
    LearningHoursMailer.learning_hours_report_email(supervisor).deliver_later
  end
end
