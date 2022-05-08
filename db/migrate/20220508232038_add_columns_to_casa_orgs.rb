class AddColumnsToCasaOrgs < ActiveRecord::Migration[7.0]
  def change
    add_column :casa_orgs, :twilio_account_sid, :string
    add_column :casa_orgs, :twilio_auth_token, :string
    add_column :casa_orgs, :twilio_phone_number, :string
  end
end
