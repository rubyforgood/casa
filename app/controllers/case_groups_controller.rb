class CaseGroupsController < ApplicationController
  before_action :require_organization!
  before_action :set_case_group, only: %i[edit update destroy]

  def index
    authorize CaseGroup
    @case_groups = policy_scope(CaseGroup).includes(:casa_cases)
  end

  def new
    @case_group = CaseGroup.new(casa_org: current_organization)
    authorize @case_group
  end

  def edit
    authorize @case_group
  end

  def create
    @case_group = current_organization.case_groups.build(case_group_params)
    authorize @case_group

    if @case_group.save
      redirect_to case_groups_path, notice: "Case group created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @case_group

    if @case_group.update(case_group_params)
      redirect_to case_groups_path, notice: "Case group updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @case_group

    @case_group.destroy
    redirect_to case_groups_path, notice: "Case group deleted!"
  end

  private

  def case_group_params
    params.merge(casa_org: current_organization)
    params.require(:case_group).permit(:name, casa_case_ids: [])
  end

  def set_case_group
    @case_group = CaseGroup.find(params[:id])
  end
end
