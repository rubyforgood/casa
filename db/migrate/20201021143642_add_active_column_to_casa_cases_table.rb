class AddActiveColumnToCasaCasesTable < ActiveRecord::Migration[6.0]
  def change
    add_column :casa_cases, :active, :boolean, default: true, null: false
  end
end
