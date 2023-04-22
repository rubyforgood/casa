class AddCasaCaseToPlacements < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :placements, :casa_case, null: false, index: {algorithm: :concurrently}
  end
end
