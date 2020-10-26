require "csv"

class CaseContactReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize :application, :see_reports_page?
    case_contact_report = CaseContactReport.new(report_params)

    respond_to do |format|
      format.csv do
        send_data case_contact_report.to_csv,
          filename: "case-contacts-report-#{Time.zone.now.to_i}.csv"
      end
    end
  end

  private

  def report_params
    params.require(:report).permit(:start_date, :end_date,
      :contact_made, :has_transitioned, :want_driving_reimbursement,
      {contact_type_ids: []},
      {contact_type_group_ids: []},
      {creator_ids: []},
      {supervisor_ids: []})
  end
end
