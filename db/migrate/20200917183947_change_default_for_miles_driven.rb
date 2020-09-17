class ChangeDefaultForMilesDriven < ActiveRecord::Migration[6.0]
  def change
    change_column :case_contacts,:miles_driven, :integer, :default => 0, :null => false
  end
end
