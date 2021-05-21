class AddCasaCaseDetailsToPastCourtDates < ActiveRecord::Migration[6.1]
  def change
    add_reference :past_court_dates, :hearing_type, null: true
    add_reference :past_court_dates, :judge, null: true
  end
end
