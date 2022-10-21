class AddUserLanguages < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :user_languages do |t|
      t.references :user
      t.references :language

      t.timestamps
    end

    add_index :user_languages, [:language_id, :user_id], unique: true, algorithm: :concurrently
  end
end
