class AddDefaultValueToCaseContactMilesDriven < ActiveRecord::Migration[6.0]
  def up
    change_column :case_contacts, :miles_driven, :integer, default: 0
    CaseContact.where(miles_driven: nil).update_all(miles_driven: 0)
  end

  def down
    change_column :case_contacts, :miles_driven, :integer, default: nil
  end
end
