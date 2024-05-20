class AddFollowupableToFollowups < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!
  # To handle Dangerous operation detected by #strong_migrations in converting followups to polymorphic we will:
  # 1. Create a new column
  # 2. Write to both columns
  # 3. Backfill data from the old column to the new column
  # 4. Move reads from the old column to the new column
  # 5. Stop writing to the old column
  # 6. Drop the old column
  #
  def change
    add_column :followups, :followupable_id, :bigint
    add_column :followups, :followupable_type, :string

    add_index :followups, [:followupable_type, :followupable_id], algorithm: :concurrently
  end
end
