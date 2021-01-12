class DropCasaOrgLogosTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :casa_org_logos
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
