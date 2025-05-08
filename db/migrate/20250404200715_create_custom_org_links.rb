class CreateCustomOrgLinks < ActiveRecord::Migration[7.2]
  def change
    create_table :custom_org_links do |t|
      t.references :casa_org, null: false, foreign_key: true
      t.string :text, null: false
      t.string :url, null: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end
  end
end
