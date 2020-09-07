class ImportsController < ApplicationController
  before_action :authenticate_user!
  before_action :must_be_admin
  before_action :check_empty_attachment, only: [:create]

  def index
    @import_type = params.fetch(:import_type, "volunteer")
  end

  def create
    import = import_from_csv(params[:import_type], params[:file], current_user.casa_org_id)
    flash[import[:type]] = import[:message]
    redirect_to imports_path(import_type: params[:import_type])
  end

  private

  def import_from_csv(import_type, file, org_id)

    unless File.file?(file)
      return { type: :error, message: "CSV import file not found: #{file}" }
    end

    case import_type
    when "volunteer"
      UserImporter.import_volunteers(file, org_id)
    when "supervisor"
      UserImporter.import_supervisors(file, org_id)
    when "casa_case"
      CaseImporter.import_cases(file, org_id)
    else
      valid_import_types_string = %w{volunteer supervisor casa_case}.to_s
      {type: :error, message: "Bad import type '#{import_type}'. Must be one of #{valid_import_types_string}." }
    end
  end

  def check_empty_attachment
    return unless params[:file].blank?
    flash[:error] = "You must attach a csv file in order to import information!"
    redirect_to imports_path(import_type: params[:import_type])
  end
end
