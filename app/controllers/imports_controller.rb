class ImportsController < ApplicationController
  include ActionView::Helpers::UrlHelper

  before_action :authenticate_user!
  before_action :must_be_admin

  def index
    @import_type = params.fetch(:import_type, "volunteer")
    @import_error = session[:import_error]
    session[:import_error] = nil
  end

  def create
    import = import_from_csv(params[:import_type], params[:file], current_user.casa_org_id)
    message = import[:message]

    # If there were failed imports
    if import[:exported_rows]
      message << "<p class='mt-4'>" + link_to("Click here to download failed rows.", download_failed_imports_path) +
        "</p>" + "<p>#{ERR_FAILED_IMPORT_NOTE}</p>"
      session[:exported_rows] = import[:exported_rows]
    end

    if import[:type] == :error
      session[:import_error] = message
    # Only use flash for success messages. Otherwise may cause CookieOverflow
    else
      flash[:success] = message
    end

    redirect_to imports_path(import_type: params[:import_type])
  end

  def download_failed
    data = session[:exported_rows]
    session[:exported_rows] = nil
    send_data data, format: :csv, filename: "failed_rows.csv"
  end

  private

  ERR_FAILED_IMPORT_NOTE = "Note: An additional 'error' column has been added to the file. " \
    "Please note the failure reason and remove the column when resubmitting."
  ERR_FILE_NOT_ATTACHED = "You must attach a CSV file in order to import information!"
  ERR_FILE_NOT_FOUND = "CSV import file not found."
  ERR_FILE_EMPTY = "File can not be empty."
  ERR_INVALID_HEADER = "Looks like this CSV contains invalid formatting. " \
    "Please download an example CSV for reference and try again."

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

  def import_from_csv(import_type, file, org_id)
    validated_file = validate_file(file, import_type)

    return validated_file unless validated_file.nil?

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
        "<b>Expected Header</b>: #{header[import_type]}.</p>" \
        "<p><b>Received Header</b>: #{file_header}</p>"

      {type: :error, message: message}
    end
  end
end
