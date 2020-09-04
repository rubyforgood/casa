class AddIsActiveToSupervisorVolunteers < ActiveRecord::Migration[6.0]
  def change
    add_column :supervisor_volunteers, :is_active, :boolean, default: true
  end
end
