class CreateSupervisorVolunteers < ActiveRecord::Migration[6.0]
  def change
    create_table :supervisor_volunteers do |t|
      t.references :supervisor, foreign_key: {to_table: :users}, null: false
      t.references :volunteer, foreign_key: {to_table: :users}, null: false

      t.timestamps
    end
  end
end
# rubocop:enable Style/Documentation
