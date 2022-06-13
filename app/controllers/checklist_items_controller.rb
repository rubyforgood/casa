class ChecklistItemsController < ApplicationController
  def new
    authorize ChecklistItem
    @hearing_type = HearingType.find(params[:hearing_type_id])
    @checklist_item = ChecklistItem.new
  end

  def create
    authorize ChecklistItem
    @hearing_type = HearingType.find(params[:hearing_type_id])
    @checklist_item = @hearing_type.checklist_items.create(checklist_item_params)
    if @checklist_item.save
      redirect_to edit_hearing_type_path(@hearing_type), notice: "Checklist Item was successfully created."
    else
      render :new
    end
  end

  private

  def checklist_item_params
    params.require(:checklist_item).permit(:category, :description, :mandatory)
  end
end
