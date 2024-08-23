class PlacementsController < ApplicationController
  before_action :set_casa_case
  before_action :set_placement, only: %i[edit show generate update destroy]
  before_action :require_organization!

  def index
    authorize Placement
    @placements = @casa_case.placements.includes(:placement_type).order(placement_started_at: :desc)
  end

  def show
    authorize @placement
  end

  def new
    @placement = Placement.new(casa_case: @casa_case)
    authorize @placement
  end

  def edit
    authorize @placement
  end

  def create
    @placement = Placement.new(placement_params)
    authorize @placement

    if @placement.save
      redirect_to casa_case_placements_path(@casa_case), notice: "Placement was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @placement

    if @placement.update(placement_params)
      redirect_to casa_case_placements_path(@casa_case), notice: "Placement was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @placement

    if @placement.destroy
      redirect_to casa_case_placements_path(@casa_case), notice: "Placement was successfully deleted."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_casa_case
    @casa_case = current_organization.casa_cases.friendly.find(params[:casa_case_id])
  end

  def set_placement
    @placement = @casa_case.placements.find(params[:id])
  end

  def placement_params
    params.require(:placement).permit(
      :placement_started_at,
      :placement_type_id
    ).merge({creator_id: current_user.id, casa_case_id: @casa_case.id})
  end
end
