class HearingTypesController < ApplicationController
  before_action :set_hearing_type, except: [:new, :create]
  after_action :verify_authorized

  def new
    authorize HearingType
    @hearing_type = HearingType.new
  end

  def create
    authorize HearingType
    @hearing_type = HearingType.new(hearing_type_params)

    if @hearing_type.save
      redirect_to edit_casa_org_path(current_organization), notice: "Hearing Type was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @hearing_type
  end

  def update
    authorize @hearing_type
    if @hearing_type.update(hearing_type_params)
      redirect_to edit_casa_org_path(current_organization), notice: "Hearing Type was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_hearing_type
    @hearing_type = HearingType.find(params[:id])
  end

  def hearing_type_params
    params.require(:hearing_type).permit(:name, :active).merge(
      casa_org: current_organization
    )
  end
end
