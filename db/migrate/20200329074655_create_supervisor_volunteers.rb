class CreateSupervisorVolunteers < ActiveRecord::Migration[6.0]
  def change
    create_table :supervisor_volunteers do |t|
      t.integer{polymorphic} :volunteer_user_id
      t.integer{polymorphic} :supervisor_user_id

      t.timestamps
    end
  end
end
