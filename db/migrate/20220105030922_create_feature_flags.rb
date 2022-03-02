class CreateFeatureFlags < ActiveRecord::Migration[6.1]
  def change
    create_table :feature_flags do |t|
      t.string :name, null: false
      t.boolean :enabled, null: false, default: false
      t.timestamps
    end
  end
end
