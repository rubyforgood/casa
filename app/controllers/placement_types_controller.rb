class PlacementTypesController < ApplicationController
  before_action :set_placement_type, only: %i[edit update]
  after_action :verify_authorized
  after_action :verify_policy_scoped

  def new
    @placement_type = policy_scope(PlacementType).new(casa_org: current_organization)
    authorize @placement_type
  end

  def create
    @placement_type = policy_scope(PlacementType).new(placement_type_params)
    authorize @placement_type

    if @placement_type.save
      redirect_to edit_casa_org_path(current_organization), notice: "Placement Type was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @placement_type
  end

  def update
    authorize @placement_type

    if @placement_type.update(placement_type_params)
      redirect_to edit_casa_org_path(current_organization), notice: "Placement Type was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_placement_type
    @placement_type = policy_scope(PlacementType).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to edit_casa_org_path
  end

  def placement_type_params
    params.require(:placement_type).permit(:name).merge(casa_org: current_organization)
  end
end
