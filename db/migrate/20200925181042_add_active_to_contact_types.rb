class AddActiveToContactTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :contact_types, :active, :boolean, default: true
  end
end
