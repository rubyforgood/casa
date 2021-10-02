class RenameCourtMandatesToCourtOrders < ActiveRecord::Migration[6.1]
  def change
    rename_table :case_court_mandates, :case_court_orders
  end
end
