class AddForeignKeyCasaCaseToPlacement < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :placements, :casa_cases, column: :casa_case_id, validate: false
  end
end
