class RemovePlainTextTokensFromApiCredentials < ActiveRecord::Migration[7.2]
  def change
    safety_assured { remove_column :api_credentials, :api_token, :string }
    safety_assured { remove_column :api_credentials, :refresh_token, :string }
  end
end
