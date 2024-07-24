class ChecklistItemsController < ApplicationController
  before_action :authorize_checklist_item
  before_action :set_hearing_type
  before_action :set_checklist_item, except: [:new, :create]

  def new
    @checklist_item = ChecklistItem.new
  end

  def create
    @checklist_item = @hearing_type.checklist_items.create(checklist_item_params)
    if @checklist_item.save
      set_checklist_updated_date(@hearing_type)
      redirect_to edit_hearing_type_path(@hearing_type), notice: "Checklist item was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @checklist_item.update(checklist_item_params)
      set_checklist_updated_date(@hearing_type)
      redirect_to edit_hearing_type_path(@hearing_type), notice: "Checklist item was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @checklist_item.destroy
      set_checklist_updated_date(@hearing_type)
      redirect_to edit_hearing_type_path(@hearing_type), notice: "Checklist item was successfully deleted."
    else
      flash[:error] = "Failed to delete checklist item."
      redirect_to edit_hearing_type_path(@hearing_type)
    end
  end

  private

  def set_checklist_updated_date(hearing_type)
    hearing_type.update_attribute(:checklist_updated_date, "Updated #{Time.new.strftime("%m/%d/%Y")}")
  end

  def authorize_checklist_item
    authorize ChecklistItem
  end

  def set_hearing_type
    @hearing_type ||= policy_scope(HearingType).find(params[:hearing_type_id])
  end

  def set_checklist_item
    @checklist_item ||= ChecklistItem.find(params[:id])
  end

  def checklist_item_params
    params.require(:checklist_item).permit(:category, :description, :mandatory)
  end
end
