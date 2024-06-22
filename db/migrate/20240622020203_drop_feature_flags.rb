class DropFeatureFlags < ActiveRecord::Migration[7.1]
  def up
    drop_table :feature_flags
  end

  def down
    create_table :feature_flags do |t|
      t.string :name, null: false
      t.boolean :enabled, null: false, default: false
      t.timestamps
    end

    add_index :feature_flags, :name, unique: true, algorithm: :concurrently
  end
end
