class CaseGroupsController < ApplicationController
  before_action :require_organization!
  before_action :authorize_admin_or_supervisor!

  def index
    @case_groups = current_organization.case_groups.includes(:casa_cases)
  end

  def new
    @case_group = CaseGroup.new
  end

  def edit
    @case_group = current_organization.case_groups.find(params[:id])
  end

  def create
    @case_group = current_organization.case_groups.build(case_group_params)
    if @case_group.save
      redirect_to case_groups_path, notice: "Case group created!"
    else
      render :new
    end
  end

  def update
    @case_group = current_organization.case_groups.find(params[:id])
    if @case_group.update(case_group_params)
      redirect_to case_groups_path, notice: "Case group updated!"
    else
      render :new
    end

  end

  def destroy
    case_group = current_organization.case_groups.find(params[:id])
    case_group.destroy
    redirect_to case_groups_path, notice: "Case group deleted!"
  end

  private

  def case_group_params
    params.require(:case_group).permit(:name, casa_case_ids: [])
  end

  def authorize_admin_or_supervisor!
    authorize :application, :admin_or_supervisor?
  end
end
