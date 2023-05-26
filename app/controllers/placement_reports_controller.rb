class PlacementReportsController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :application, :see_reports_page?
    placement_report = PlacementExportCsvService.new(casa_org: current_organization).perform

    respond_to do |format|
      format.csv do
        send_data placement_report,
          filename: "placement-report-#{Time.current.strftime("%Y-%m-%d")}.csv"
      end
    end
  end
end
