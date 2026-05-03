class ReportsController < ApplicationController
  after_action :verify_authorized
  skip_after_action :verify_policy_scoped # TODO: index should call policy_scope; remove this skip once it does

  def index
    authorize :application, :see_reports_page?
  end

  def export_emails
    authorize :application, :see_reports_page?

    respond_to do |format|
      format.csv do
        send_data VolunteersEmailsExportCsvService.new(current_user.casa_org).call,
          filename: "volunteers-emails-#{Time.current.strftime("%Y-%m-%d")}.csv"
      end
    end
  end
end
