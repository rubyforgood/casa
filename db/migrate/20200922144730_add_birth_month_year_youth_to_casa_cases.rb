class AddBirthMonthYearYouthToCasaCases < ActiveRecord::Migration[6.0]
  def change
    add_column :casa_cases, :birth_month_year_youth, :datetime
  end
end
