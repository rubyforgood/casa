class CreateApiCredentials < ActiveRecord::Migration[7.2]
  def change
    create_table :api_credentials do |t|
      t.references :user, null: false, foreign_key: true
      t.string :api_token
      t.string :refresh_token
      t.datetime :token_expires_at, default: -> { "NOW() + INTERVAL '7 hours'" }
      t.datetime :refresh_token_expires_at, default: -> { "NOW() + INTERVAL '30 days'" }

      t.string :api_token_digest
      t.string :refresh_token_digest

      t.timestamps
    end

    add_index :api_credentials, :api_token_digest, unique: true, where: "api_token_digest IS NOT NULL"
    add_index :api_credentials, :refresh_token_digest, unique: true, where: "refresh_token_digest IS NOT NULL"
  end
end
