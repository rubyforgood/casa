class PlacementsController < ApplicationController
  before_action :set_casa_case
  before_action :set_placement, only: %i[edit show generate update destroy]
  before_action :require_organization!

  rescue_from ActiveRecord::RecordNotFound, with: -> { head :not_found }

  def index
    authorize @casa_case
    @placements = @casa_case.placements.includes(:placement_type).order(placement_started_at: :desc)
  end

  def new
    authorize @casa_case
    @placement = Placement.new
  end

  def edit
    authorize @casa_case
  end

  def create
    @placement = Placement.new(placement_params)
    authorize @placement

    if @placement.save
      redirect_to casa_case_placements_path(@casa_case), notice: "Placement was successfully created."
    else
      Rails.logger.error("Placement creation failed: #{@placement.errors.full_messages}")
      flash.now[:alert] = "Failed to create placement: #{@placement.errors.full_messages.join(", ")}"
      render :new, status: :unprocessable_entity
    end
  rescue Pundit::NotAuthorizedError => e
    Rails.logger.error("Authorization failed: #{e.message}")
    redirect_to casa_case_placements_path, alert: "You are not authorized to create a placement for this case."
  end

  def update
    authorize @placement

    if @placement.update(placement_params)
      redirect_to casa_case_placements_path(@casa_case), notice: "Placement was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  rescue Pundit::NotAuthorizedError => e
    Rails.logger.error("Authorization failed: #{e.message}")
    redirect_to casa_case_placements_path, alert: "You are not authorized to create a placement for this case."
  end

  def destroy
    authorize @placement
    if @placement.destroy
      redirect_to casa_case_placements_path(@casa_case), notice: "Placement was successfully deleted."
    else
      render :edit, status: :unprocessable_entity
    end
  rescue Pundit::NotAuthorizedError => e
    Rails.logger.error("Authorization failed: #{e.message}")
    redirect_to casa_case_placements_path, alert: "You are not authorized to delete placements for this case."
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
