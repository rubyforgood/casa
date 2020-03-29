class CreateSupervisorVolunteers < ActiveRecord::Migration[6.0]
  def change
    create_table :supervisor_volunteers do |t|
      t.references :supervisor_user, foreign_key: { to_table: :users }
      t.references :volunteer_user, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
