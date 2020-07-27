class ImportsController < ApplicationController
  before_action :authenticate_user!
  before_action :must_be_admin

  def index; end

  def import_volunteers
    FileImporter.import_volunteers(params[:file], current_user.casa_org_id)
    flash[:success] = "Volunteers imported"
    redirect_to imports_path
  end

  def import_supervisors
    FileImporter.import_supervisors(params[:file], current_user.casa_org_id)
    flash[:success] = "Supervisors imported"
    redirect_to imports_path
  end

  def import_cases
    User.import_volunteers(params[:file], current_user.casa_org_id)
    flash[:success] = "Cases imported"
    redirect_to imports_path
  end
end
