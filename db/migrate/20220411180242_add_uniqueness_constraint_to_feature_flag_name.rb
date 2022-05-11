class AddUniquenessConstraintToFeatureFlagName < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :feature_flags, :name, unique: true, algorithm: :concurrently
  end
end
