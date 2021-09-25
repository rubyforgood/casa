class AddSlugToCasaOrgsAndCasaCases < ActiveRecord::Migration[6.1]
  def change
    add_column :casa_cases, :slug, :string
    add_column :casa_orgs, :slug, :string
    add_index :casa_cases, :slug
    add_index :casa_orgs, :slug, unique: true
  end
end
