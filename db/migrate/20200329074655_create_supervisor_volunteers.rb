class CreateSupervisorVolunteers < ActiveRecord::Migration[6.0]
  def change
    create_table :supervisor_volunteers do |t|
      t.integer :volunteer_user_id
      t.integer :supervisor_user_id

      t.timestamps
    end
  end
end
