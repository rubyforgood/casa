desc "Send learning hours report to all Casa Admins and Supervisors; run daily in Heroku Scheduler, only acts on the 1st"
task send_learning_hour_reports: :environment do
  first_of_month = ->(org) {
    if Time.now.utc == Time.now.utc.midnight
      Time.now.utc.to_date.day == 1
    else
      org.today.day == 1
    end
  }

  CasaOrg.find_each do |org|
    org.with_time_zone do
      next unless first_of_month.call(org) || ENV["FORCE"] == "true"

      start_of_month = org.time_zone_now.beginning_of_month.utc

      admins = org.casa_admins.active.where(monthly_learning_hours_report: true)
      supervisors = org.supervisors.active.where(monthly_learning_hours_report: true)

      admins.find_each do |admin|
        next if SentEmail.where(user_id: admin.id, mailer_type: "LearningHoursMailer").where("created_at >= ?", start_of_month).exists?

        LearningHoursMailer.learning_hours_report_email(admin).deliver_later
      end

      supervisors.find_each do |supervisor|
        next if SentEmail.where(user_id: supervisor.id, mailer_type: "LearningHoursMailer").where("created_at >= ?", start_of_month).exists?

        LearningHoursMailer.learning_hours_report_email(supervisor).deliver_later
      end
    end
  rescue => e
    Rails.logger.error("Failed sending learning hours report for CasaOrg #{org.id}: #{e.message}")
  end
end
