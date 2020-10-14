# frozen_string_literal: true

class CaseCourtReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_casa_case, only: %i[show check_access]

  # GET /case_court_reports
  def index
    @assigned_cases = CasaCase.actively_assigned_to(current_user)
                              .select(:id, :case_number, :transition_aged_youth)
  end

  # GET /case_court_reports/:id
  def show
    report_path = path_to_report(params[:id])

    unless File.exist?(report_path)
      flash[:error] = 'File is not found.'
      redirect_to case_court_reports_path and return
    end

    respond_to do |format|
      format.docx { send_file report_path, type: :docx, disposition: 'attachment', status: :ok }
    end
  end

  # POST /case_court_reports
  def generate
    casa_case   = CasaCase.find_by(case_params)

    report      = generate_report(casa_case)
    client_link = generate_case_court_reports_path.gsub('generate', report_file_name(casa_case.case_number))
    status      = File.exist?(report.report_path) ? :ok : :not_found

    respond_to do |format|
      format.json do
        render json: { link: client_link, status: status }
      end
    end
  end

  private

  def case_params
    params.require(:case_court_report).permit(:case_number)
  end

  def set_casa_case
    @casa_case = CasaCase.find_by(case_number: params[:id])
  end

  def generate_report(casa_case)
    return unless casa_case

    type = report_type(casa_case)
    court_report = CaseCourtReport.new(
      volunteer_id: current_user.id,
      case_id: casa_case.id,
      path_to_template: path_to_template(type),
      path_to_report: path_to_report(casa_case.case_number)
    )
    court_report.generate!
    court_report
  end

  def report_type(casa_case)
    casa_case.has_transitioned? ? 'transition' : 'non_transition'
  end

  def directory_to_template
    directory = "tmp/reports"

    FileUtils.mkdir_p directory unless File.directory?(directory)

    directory
  end

  def report_file_name(case_number)
    "#{case_number}.docx"
  end

  def path_to_report(case_number)
    "#{directory_to_template}/#{report_file_name(case_number)}"
  end

  def path_to_template(type)
    "app/documents/templates/report_template_#{type}.docx"
  end
end
