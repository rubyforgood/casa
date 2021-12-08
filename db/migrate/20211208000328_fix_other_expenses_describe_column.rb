class FixOtherExpensesDescribeColumn < ActiveRecord::Migration[6.1]
  def change
    rename_column :additional_expenses, "other-expenses-describe", "other_expenses_describe"
  end
end
