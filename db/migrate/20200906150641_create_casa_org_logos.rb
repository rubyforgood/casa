class CreateCasaOrgLogos < ActiveRecord::Migration[6.0]
  def change
    create_table :casa_org_logos do |t|
      t.references :casa_org, null: false, foreign_key: true
      t.string :url
      t.string :alt_text
      t.string :size

      t.timestamps
    end
  end
end
