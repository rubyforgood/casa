class AddDateInCareToCasaCases < ActiveRecord::Migration[7.0]
  def change
    add_column :casa_cases, :date_in_care, :datetime
  end
end
