class CreateCaseAssignments < ActiveRecord::Migration[6.0]
  def change
    create_table :case_assignments do |t|
      t.references :casa_case, foreign_key: {to_table: :casa_cases}, null: false
      t.references :volunteer, foreign_key: {to_table: :users}, null: false
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end
  end
end
# rubocop:enable Style/Documentation
