class PlacementsController < ApplicationController
  before_action :set_casa_case
  before_action :set_placement, only: %i[edit show generate update destroy]
  before_action :require_organization!

  rescue_from ActiveRecord::RecordNotFound, with: -> { head :not_found }

  def show
    authorize @casa_case
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
  end

  private

  def set_casa_case
    @casa_case = current_organization.casa_cases.friendly.find(params[:casa_case_id])
  end

  def set_placement
    @placement = @casa_case.placements.find(params[:id])
  end
end
