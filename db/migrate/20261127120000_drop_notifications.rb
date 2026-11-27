class DropNotifications < ActiveRecord::Migration[8.1]
  # Legacy Noticed v1 table. Its rows were copied into noticed_events / noticed_notifications by
  # the 20240604121427_migrate_notifications after_party task, and nothing has used it since.
  # The column list lets `down` recreate the (empty) table.
  def change
    drop_table :notifications do |t|
      t.datetime :created_at, null: false
      t.jsonb :params
      t.datetime :read_at, precision: nil
      t.bigint :recipient_id, null: false
      t.string :recipient_type, null: false
      t.string :type, null: false
      t.datetime :updated_at, null: false
    end
  end
end
