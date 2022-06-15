class AddHideOldContactsToCaseAssignment < ActiveRecord::Migration[7.0]
  def change
    add_column :case_assignments, :hide_old_contacts, :boolean, default: false
  end
end
