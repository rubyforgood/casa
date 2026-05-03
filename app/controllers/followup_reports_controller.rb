# frozen_string_literal: true

class FollowupReportsController < ApplicationController
  after_action :verify_authorized
  skip_after_action :verify_policy_scoped # TODO: index should call policy_scope; remove this skip once it does

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
