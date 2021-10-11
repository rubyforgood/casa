class RemoveMandateTextFromCaseCourtOrders < ActiveRecord::Migration[6.1]
  def change
    remove_column :case_court_orders, :mandate_text, :string
  end
end
