class CreateHealths < ActiveRecord::Migration[6.1]
  def change
    create_table :healths do |t|
      t.timestamp :latest_deploy_time
      t.integer :singleton_guard

      t.timestamps
    end

    add_index(:healths, :singleton_guard, unique: true)
  end
end
