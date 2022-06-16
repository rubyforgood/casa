class AddChecklistUpdatedDateToHearingTypes < ActiveRecord::Migration[7.0]
  def change
    add_column :hearing_types, :checklist_updated_date, :string, default: "None", null: false
  end
end
