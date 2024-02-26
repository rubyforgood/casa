# frozen_string_literal: true

class CaseCourtReportsController < ApplicationController
  before_action :set_casa_case, only: %i[show]
  after_action :verify_authorized

  def index
    authorize CaseCourtReport
    assigned_cases.select(:id, :case_number, :birth_month_year_youth)
  end

  def show
    authorize CaseCourtReport
    if !@casa_case || !@casa_case.court_reports.attached?
      flash[:alert] = "Report #{params[:id]} is not found."
      redirect_to(case_court_reports_path) and return
    end

    respond_to do |format|
      format.docx do
        @casa_case.latest_court_report.open do |file|
          # TODO test this .read being present, we've broken it twice now
          send_data File.read(file.path), type: :docx, disposition: "attachment", status: :ok
        end
      end
    end
  end

  def generate
    authorize CaseCourtReport
    casa_case = CasaCase.find_by(case_params)
    respond_to do |format|
      format.json do
        if casa_case
          report_data = generate_report_to_string(casa_case, params[:time_zone])
          save_report(report_data, casa_case)

          render json: {link: case_court_report_path(casa_case.case_number, format: "docx"), status: :ok}
        else
          error_messages = generate_error("Report #{params[:case_number]} is not found.")

          render json: {link: "", status: :not_found, error_messages: error_messages}, status: :not_found
        end
      end
    end
  rescue Zip::Error
    error_messages = generate_error("Template is not found")
    render json: {status: :not_found, error_messages: error_messages}, status: :not_found
  rescue => e
    error_messages = generate_error(e.to_s)
    render json: {status: :unprocessable_entity, error_messages: error_messages}, status: :unprocessable_entity
  end

  private

  def case_params
    params.require(:case_court_report).permit(:case_number)
  end

  def set_casa_case
    @casa_case = CasaCase.find_by(case_number: params[:id])
  end

  def assigned_cases
    @assigned_cases = if current_user.volunteer?
      CasaCase.actively_assigned_to(current_user)
    else
      current_user.casa_org.casa_cases.active
    end
  end

  # TODO: Add contact topics here somewhere?
  def generate_report_to_string(casa_case, time_zone)
    return unless casa_case

    casa_case.casa_org.open_org_court_report_template do |template_docx_file|
      args = {
        volunteer_id: current_user.volunteer? ? current_user.id : casa_case.assigned_volunteers.first&.id,
        case_id: casa_case.id,
        path_to_template: template_docx_file.to_path,
        time_zone: time_zone
      }
      context = CaseCourtReportContext.new(args).context
      court_report = CaseCourtReport.new(path_to_template: template_docx_file.to_path, context: context)

      return court_report.generate_to_string
    end
  end

  def save_report(report_data, casa_case)
    Tempfile.create do |t|
      t.binmode.write(report_data)
      t.rewind
      casa_case.court_reports.attach(
        io: File.open(t.path), filename: "#{casa_case.case_number}.docx"
      )
    end
  end

  def generate_error(message)
    flash[:alert] = message
    error_messages = render_to_string partial: "layouts/flash_messages", formats: :html, layout: false, locals: flash
    flash.discard

    error_messages
  end
end
