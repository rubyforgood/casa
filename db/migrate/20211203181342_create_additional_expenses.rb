class CreateAdditionalExpenses < ActiveRecord::Migration[6.1]
  def change
    create_table :additional_expenses do |t|
      t.references :case_contact, null: false, foreign_key: true
      t.decimal "other_expense_amount"
      t.string "other_expenses_describe"

      t.timestamps
    end
  end
end
