class CreatePlacements < ActiveRecord::Migration[7.0]
  def change
    create_table :placements do |t|
      # Add table placement_type: name, casa_org_id. Add table placement: placement_id, casa_case_id, started_at, created_by_id (links to user table)
      t.datetime :placement_started_at, null: false
      t.references :placement_type, null: false, foreign_key: true
      t.references :creator, foreign_key: {to_table: :users}, null: false
      t.timestamps
    end
  end
end
