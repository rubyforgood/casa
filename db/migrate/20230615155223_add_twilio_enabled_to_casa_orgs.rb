class AddTwilioEnabledToCasaOrgs < ActiveRecord::Migration[7.0]
  def change
    add_column :casa_orgs, :twilio_enabled, :boolean, default: false
  end
end
