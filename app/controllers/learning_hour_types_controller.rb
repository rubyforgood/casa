class LearningHourTypesController < ApplicationController
  before_action :set_learning_hour_type, only: %i[edit update]
  after_action :verify_authorized

  def new
    authorize LearningHourType
    @learning_hour_type = LearningHourType.new
  end

  def edit
    authorize @learning_hour_type
  end

  def create
    authorize LearningHourType
    @learning_hour_type = LearningHourType.new(learning_hour_type_params)

    if @learning_hour_type.save
      redirect_to edit_casa_org_path(current_organization), notice: "Learning Type was successfully created."
    else
      render :new
    end
  end

  def update
    authorize @learning_hour_type

    if @learning_hour_type.update(learning_hour_type_params)
      redirect_to edit_casa_org_path(current_organization), notice: "Learning Type was successfully updated."
    else
      render :edit
    end
  end

  private

  def set_learning_hour_type
    @learning_hour_type = LearningHourType.find(params[:id])
  end

  def learning_hour_type_params
    params.require(:learning_hour_type).permit(:name, :active).merge(
      casa_org: current_organization
    )
  end
end
