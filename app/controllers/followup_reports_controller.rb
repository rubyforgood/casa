class FollowupReportsController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :application, :see_reports_page?
    followup_report = FollowupExportCsvService.new(current_organization).perform

    respond_to do |format|
      format.csv do
        send_data followup_report,
          filename: "followup-report-#{Time.current.strftime("%Y-%m-%d")}.csv"
      end
    end
  end
end
