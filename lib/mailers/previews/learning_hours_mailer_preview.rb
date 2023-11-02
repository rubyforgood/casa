require_relative "../debug_preview_mailer"

class LearningHoursMailerPreview < ActionMailer::Preview
  def learning_hours_report_email
    current_user = params.has_key?(:id) ? User.find_by(id: params[:id]) : User.first

    if current_user.nil?
      DebugPreviewMailer.invalid_user("user")
    else
      LearningHoursMailer.learning_hours_report_email(current_user)
    end
  end
end
