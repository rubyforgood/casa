class LearningHoursReportsController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :application, :see_reports_page?
    learning_hours_report = LearningHoursReport.new(current_organization.id)

    respond_to do |format|
      format.csv do
        send_data learning_hours_report.to_csv,
                  filename: "learning-hours-report-#{Time.current.strftime("%Y-%m-%d")}.csv"
      end
    end
  end
end

