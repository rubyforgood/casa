require "csv"

class CaseContactReportsController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :application, :see_reports_page?
    case_contact_report = CaseContactReport.new(report_params)

    respond_to do |format|
      format.csv do
        send_data case_contact_report.to_csv,
          filename: "case-contacts-report-#{Time.zone.now.to_i}.csv"
      end

      format.xlsx do
        send_data case_contact_report.to_excel,
          filename: "case-contacts-report-#{Time.zone.now.to_i}.xlsx"
      end
    end
  end

  private

  def report_params
    parameters = params.require(:report).permit(
      :start_date,
      :end_date,
      :contact_made,
      :has_transitioned,
      :want_driving_reimbursement,
      :other_expense_amount,
      :other_expenses_describe,
      contact_type_ids: [],
      contact_type_group_ids: [],
      creator_ids: [],
      supervisor_ids: [],
      casa_case_ids: [],
      filtered_csv_cols: {},
      report_format: ""
    ).merge(casa_org_id: current_organization.id)
    convert_radio_options_to_boolean(parameters)
    parameters
  end

  def convert_radio_options_to_boolean(parameters)
    parameters[:contact_made] = string_to_boolean(parameters[:contact_made])
    parameters[:has_transitioned] = string_to_boolean(parameters[:has_transitioned])
    parameters[:want_driving_reimbursement] = string_to_boolean(parameters[:want_driving_reimbursement])
  end

  def string_to_boolean(value)
    if value == "true"
      true
    else
      (value == "false" ? false : "")
    end
  end
end
