class ReportsController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :application, :see_reports_page?
  end

  def export_emails
    authorize :application, :see_reports_page?
    debugger
    respond_to do |format|
      format.csv do
        send_data VolunteersEmailsExportCsvService.new(current_user.casa_org).call,
          filename: "volunteers-emails-#{Time.current.strftime("%Y-%m-%d")}.csv"
      end
    end
  end
end
