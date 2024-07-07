class PlacementTypesController < ApplicationController
  before_action :set_placement_type, only: %i[edit update]

  def new
    authorize PlacementType
    @placement_type = PlacementType.new
  end

  def edit
    authorize @placement_type
  end

  def create
    authorize PlacementType
    @placement_type = PlacementType.new(placement_type_params)
    @placement_type.casa_org = current_organization
    respond_to do |format|
      if @placement_type.save
        format.html { redirect_to edit_casa_org_path(current_organization.id), notice: "Placement Type was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @placement_type
    respond_to do |format|
      if @placement_type.update(placement_type_params)
        format.html { redirect_to edit_casa_org_path(current_organization.id), notice: "Placement Type was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_placement_type
    @placement_type = PlacementType.find(params[:id])
  end

  def placement_type_params
    params.require(:placement_type).permit(:name)
  end
end
