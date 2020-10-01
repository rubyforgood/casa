class SetMilesDrivenAsNotNullable < ActiveRecord::Migration[6.0]
  def up
    change_column :case_contacts, :miles_driven, :integer, null: false
  end

  def down
    change_column :case_contacts, :miles_driven, :integer, null: true
  end
end
