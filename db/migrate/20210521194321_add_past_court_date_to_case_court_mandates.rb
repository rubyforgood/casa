class AddPastCourtDateToCaseCourtMandates < ActiveRecord::Migration[6.1]
  def change
    add_reference :case_court_mandates, :past_court_date, null: true
  end
end
