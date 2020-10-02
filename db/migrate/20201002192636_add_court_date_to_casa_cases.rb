class AddCourtDateToCasaCases < ActiveRecord::Migration[6.0]
  def change
    add_column :casa_cases, :court_date, :datetime
  end
end
