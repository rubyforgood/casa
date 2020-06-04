require "csv"

class CaseContactReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    case_contact_report = CaseContactReport.new

    respond_to do |format|
      format.csv do
        send_data case_contact_report.to_csv,
                  filename: "case-contacts-report-#{Time.zone.now.to_i}.csv"
      end
    end
  end

  private

  def report_params
    params.require(:case_contact_report).permit(:start_date, :end_date)
  end
end
