class AddActiveToContactTypeGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :contact_type_groups, :active, :boolean, default: true
  end
end
