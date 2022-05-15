class AddColumnsToCasaOrgs < ActiveRecord::Migration[7.0]
  def change
    add_column :casa_orgs, :twilio_phone_number, :string
    add_column :casa_orgs, :twilio_account_sid, :string
    add_column :casa_orgs, :twilio_api_key_sid, :string
    add_column :casa_orgs, :twilio_api_key_secret, :string
  end
end
