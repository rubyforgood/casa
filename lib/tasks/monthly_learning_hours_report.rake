desc "Scheduled once per month in Heroku Scheduler, this task will send a learning hours report to all Casa Admins and Supervisors"
task send_learning_hour_reports: :environment do
  admins = CasaAdmin.active.where(monthly_learning_hours_report: true)
  supervisors = Supervisor.active.where(monthly_learning_hours_report: true)

  admins.each do |admin|
    LearningHoursMailer.learning_hours_report_email(admin).deliver
  end

  supervisors.each do |supervisor|
    LearningHoursMailer.learning_hours_report_email(supervisor).deliver
  end
end