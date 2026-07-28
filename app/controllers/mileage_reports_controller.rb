# frozen_string_literal: true

require "csv"

class MileageReportsController < ApplicationController
  after_action :verify_authorized
  skip_after_action :verify_policy_scoped # TODO: index should call policy_scope; remove this skip once it does

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
