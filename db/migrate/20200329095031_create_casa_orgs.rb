class CreateCasaOrgs < ActiveRecord::Migration[6.0]
  def change
    create_table :casa_orgs do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
