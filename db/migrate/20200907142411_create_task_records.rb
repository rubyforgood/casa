class CreateTaskRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :task_records, :id => false do |t|
      t.string :version, :null => false
    end
  end
end