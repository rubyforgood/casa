class ImportsController < ApplicationController
  require "csv"

  include ActionView::Helpers::UrlHelper
  after_action :verify_authorized

  ERR_FAILED_IMPORT_NOTE = "Note: An additional 'error' column has been added to the file. " \
    "Please note the failure reason and remove the column when resubmitting."
  ERR_FILE_NOT_ATTACHED = "You must attach a CSV file in order to import information!"
  ERR_FILE_NOT_FOUND = "CSV import file not found."
  ERR_FILE_EMPTY = "File can not be empty."
  ERR_INVALID_HEADER = "Looks like this CSV contains invalid formatting. " \
    "Please download an example CSV for reference and try again."

  def index
    authorize :import
    @import_type = params.fetch(:import_type, "volunteer")
    @import_error = session[:import_error]
    @sms_opt_in_warning = session[:sms_opt_in_warning]
    session[:import_error] = nil
    session[:sms_opt_in_warning] = nil
  end

  def create
    authorize :import
    import = import_from_csv(params[:import_type], params[:sms_opt_in], params[:file], current_user.casa_org_id)
    message = import[:message]

    # If there were failed imports
    if import[:exported_rows]
      message << "<p class='mt-4'>" + link_to("Click here to download failed rows.", download_failed_imports_path) +
        "</p>" + "<p>#{ERR_FAILED_IMPORT_NOTE}</p>"
      session[:exported_rows] = import[:exported_rows]
    end

    if import[:type] == :error
      session[:import_error] = message
    elsif import[:type] == :sms_opt_in_warning
      session[:sms_opt_in_warning] = import[:import_type]
    # Only use flash for success messages. Otherwise may cause CookieOverflow
    else
      flash[:success] = message
    end

    redirect_to imports_path(import_type: params[:import_type])
  end

  def download_failed
    authorize :import
    data = session[:exported_rows]
    session[:exported_rows] = nil
    send_data data, format: :csv, filename: "failed_rows.csv"
  end

  private

  def header
    {
      "volunteer" => VolunteerImporter::IMPORT_HEADER,
      "supervisor" => SupervisorImporter::IMPORT_HEADER,
      "casa_case" => CaseImporter::IMPORT_HEADER
    }
  end

  def header_valid?(file_header, import_type)
    file_header == header[import_type]
  end

  def import_from_csv(import_type, sms_opt_in, file, org_id)
    validated_file = validate_file(file, import_type)

    return validated_file unless validated_file.nil?

    if requires_sms_opt_in(file, import_type, sms_opt_in)
      return {type: :sms_opt_in_warning, import_type: import_type}
    end

    case import_type
    when "volunteer"
      VolunteerImporter.import_volunteers(file, org_id)
    when "supervisor"
      SupervisorImporter.import_supervisors(file, org_id)
    when "casa_case"
      CaseImporter.import_cases(file, org_id)
    else
      valid_import_types_string = %w[volunteer supervisor casa_case].to_s
      {type: :error, message: "Bad import type '#{import_type}'. Must be one of #{valid_import_types_string}."}
    end
  end

  def validate_file(file, import_type)
    # Validate that file is attached
    if file.blank?
      return {type: :error, message: ERR_FILE_NOT_ATTACHED}
    end

    # Validate that file exists
    unless File.file?(file)
      return {type: :error, message: ERR_FILE_NOT_FOUND + ": #{file}"}
    end

    # Validate that the file is not empty
    if File.zero?(file)
      return {type: :error, message: ERR_FILE_EMPTY}
    end

    # Validate header
    file_header = File.open(file, "r:bom|utf-8", &:readline).squish.split(",")

    unless header_valid?(file_header, import_type)
      message = "#{ERR_INVALID_HEADER}<p class='mt-4'>" \
        "<b>Expected Header</b>: #{header[import_type].join(", ")}.</p>" \
        "<p><b>Received Header</b>: #{file_header.join(", ")}</p>"

      {type: :error, message: message}
    end
  end

  def requires_sms_opt_in(file, import_type, sms_opt_in)
    if (import_type == "volunteer" || import_type == "supervisor") && import_contains_phone_numbers(file)
      return sms_opt_in != "1"
    end

    false
  end

  def import_contains_phone_numbers(file)
    CSV.foreach(file, headers: true, header_converters: :symbol) do |row|
      phone_number = row[:phone_number]
      if !phone_number.nil? && !phone_number.strip.empty?
        return true
      end
    end

    false
  end
end
