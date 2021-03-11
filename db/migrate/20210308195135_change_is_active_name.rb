class ChangeIsActiveName < ActiveRecord::Migration[6.1]
  def change
    rename_column :case_assignments, :is_active, :active
  end
end
