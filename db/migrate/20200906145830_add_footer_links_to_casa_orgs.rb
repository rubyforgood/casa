class AddFooterLinksToCasaOrgs < ActiveRecord::Migration[6.0]
  def change
    add_column :casa_orgs, :footer_links, :string, array: true, default: []
  end
end
