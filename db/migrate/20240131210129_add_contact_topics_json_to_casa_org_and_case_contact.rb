class AddContactTopicsJsonToCasaOrgAndCaseContact < ActiveRecord::Migration[7.0]
  def change
    add_column :casa_orgs, :contact_topics, :jsonb, default: []
    add_column :case_contacts, :contact_topics, :jsonb, default: []
  end
end
