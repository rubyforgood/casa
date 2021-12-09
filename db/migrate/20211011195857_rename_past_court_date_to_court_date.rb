class RenamePastCourtDateToCourtDate < ActiveRecord::Migration[6.1]
  def change
    rename_table :past_court_dates, :court_dates
    rename_column :case_court_orders, :past_court_date_id, :court_date_id
  end
end
