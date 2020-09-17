class AddDefaultValueToCaseContactMilesDriven < ActiveRecord::Migration[6.0]
  def up
    change_column :case_contacts, :miles_driven, :integer, default: 0, null: false
  end

  def down
    change_column :case_contacts, :miles_driven, :integer, default: false, null: true
  end
end
