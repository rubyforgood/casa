class LearningHoursMailer < ApplicationMailer
  def learning_hours_report_email(user)
    # user is either an Admin or Supervisor, this mailer is invoked through the rake task :monthly_learning_hours_report.rake
    @user = user
    @casa_org = @user.casa_org

    # Generate the learning hours CSV for the current month
    start_date = Date.today.beginning_of_month
    end_date = Date.today.end_of_month
    learning_hours = LearningHour.where(user: @casa_org.users, occurred_at: start_date..end_date)
    csv_data = LearningHoursExportCsvService.new(learning_hours).perform

    attachments["learning-hours-report-#{Date.today}.csv"] = csv_data

    mail(to: @user.email, subject: "Learning Hours Report for #{end_date.strftime("%B, %Y")}.")
  end
end
