class HearingTypesController < ApplicationController
  before_action :authenticate_user!, :must_be_admin
  before_action :set_hearing_type, except: [:new, :create]

  def new
    @hearing_type = HearingType.new
  end

  def create
    @hearing_type = HearingType.new(hearing_type_params)

    respond_to do |format|
      if @hearing_type.save
        format.html { redirect_to edit_casa_org_path(current_organization), notice: "Hearing Type was successfully created." }
      else
        format.html { render :new }
      end
    end
  end

  def edit
  end

  def update
    if @hearing_type.update(hearing_type_params)
      redirect_to edit_casa_org_path(current_organization), notice: "Hearing Type was successfully updated."
    else
      render :edit
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
