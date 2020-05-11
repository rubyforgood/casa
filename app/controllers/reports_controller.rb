require "csv"

class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def show
    case_contact_report = CaseContactReport.new(CaseContact.all)

    respond_to do |format|
      format.csv do
        send_data case_contact_report.to_csv,
          filename: "case-contacts-report-#{Time.zone.now.to_i}.csv"
      end
    end
  end
end
