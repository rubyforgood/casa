class AddTextToCaseCourtOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :case_court_orders, :text, :string
  end
end
