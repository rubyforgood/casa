class CreateCaseCourtMandates < ActiveRecord::Migration[6.1]
  def change
    create_table :case_court_mandates do |t|
      t.string :mandate_text

      t.timestamps
    end
  end
end
