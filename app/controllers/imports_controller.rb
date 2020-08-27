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

  def import_from_csv(import_type, file, org)
    case import_type
    when "volunteer"
      UserImporter.new(file, org).import_volunteers
    when "supervisor"
      UserImporter.new(file, org).import_supervisors
    when "casa_case"
      CaseImporter.new(file, org).import_cases
    else
      {type: :error, message: "Something went wrong with the import, did you attach a csv file?"}
    end
  end

  def check_empty_attachment
    return unless params[:file].blank?
    flash[:error] = "You must attach a csv file in order to import information!"
    redirect_to imports_path(import_type: params[:import_type])
  end
end
