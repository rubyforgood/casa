require "csv"

class MileageReportsController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :application, :see_reports_page?
    mileage_report = MileageReport.new(current_organization.id)

    respond_to do |format|
      format.csv do
        send_data mileage_report.to_csv,
          filename: "mileage-report-#{Time.current.strftime("%Y-%m-%d")}.csv"
      end
    end
  end
end
