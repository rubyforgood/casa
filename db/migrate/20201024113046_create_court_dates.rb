class CreateCourtDates < ActiveRecord::Migration[6.0]
  def change
    create_table :court_dates do |t|
      t.datetime :date, null: false
      t.references :casa_case, null: false, foreign_key: true

      t.timestamps
    end
  end
end
