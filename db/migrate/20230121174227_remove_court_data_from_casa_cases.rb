class RemoveCourtDataFromCasaCases < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :casa_cases, :court_date }
  end
end
