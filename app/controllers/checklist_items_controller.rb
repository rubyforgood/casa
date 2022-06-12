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
    redirect_to edit_hearing_type_path(@hearing_type)
  end

  private

  def checklist_item_params
    params.require(:checklist_item).permit(:category, :description, :mandatory)
  end
end
