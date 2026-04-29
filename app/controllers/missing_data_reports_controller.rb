class MissingDataReportsController < ApplicationController
  after_action :verify_authorized
  skip_after_action :verify_policy_scoped # TODO: index should call policy_scope; remove this skip once it does

  def index
    authorize :application, :see_reports_page?
    missing_data_report = MissingDataReport.new(current_organization.id)

    respond_to do |format|
      format.csv do
        send_data missing_data_report.to_csv,
          filename: "missing-data-report-#{Time.current.strftime("%Y-%m-%d")}.csv"
      end
    end
  end
end
