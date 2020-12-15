# frozen_string_literal: true

class CaseCourtReportsController < ApplicationController
  before_action :set_casa_case, only: %i[show]
  after_action :verify_authorized

  # GET /case_court_reports
  def index
    authorize :case_court_reports
    @assigned_cases = CasaCase.actively_assigned_to(current_user)
      .select(:id, :case_number, :transition_aged_youth)
  end

  # GET /case_court_reports/:id
  def show
    authorize :case_court_reports
    unless @casa_case
      flash[:alert] = "Report #{params[:id]} is not found."
      redirect_to(case_court_reports_path) and return # rubocop:disable Style/AndOr
    end

    respond_to do |format|
      format.docx do
        report_data = generate_report_to_string(@casa_case)
        send_report(report_data)
      end
    end
  end

  # POST /case_court_reports
  def generate
    authorize :case_court_reports
    casa_case = CasaCase.find_by(case_params)

    respond_to do |format|
      format.json do
        if casa_case
          render json: {link: case_court_report_path(casa_case.case_number, format: "docx"), status: :ok}
        else
          flash[:alert] = "Report #{params[:case_number]} is not found."
          error_messages = render_to_string partial: "layouts/flash_messages.html.erb", layout: false, locals: flash
          flash.discard

          render json: {link: "", status: :not_found, error_messages: error_messages}, status: :not_found
        end
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

  def generate_report_to_string(casa_case)
    return unless casa_case

    type = report_type(casa_case)
    court_report = CaseCourtReport.new(
      volunteer_id: current_user.id,
      case_id: casa_case.id,
      path_to_template: path_to_template(type)
    )
    court_report.generate_to_string
  end

  def report_type(casa_case)
    casa_case.has_transitioned? ? "transition" : "non_transition"
  end

  def path_to_template(type)
    "app/documents/templates/report_template_#{type}.docx"
  end

  # Use Tempfile Utility Class to generate a temporary file from the Word template into memory
  def send_report(data)
    Tempfile.create do |t|
      t.binmode
      t.write(data)
      t.rewind
      t.close

      # `rb` = read-binary mode
      send_data File.open(t.path, "rb").read, type: :docx, disposition: "attachment", status: :ok
    end
  end
end
