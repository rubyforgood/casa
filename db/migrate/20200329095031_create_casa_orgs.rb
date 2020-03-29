class CreateCasaOrgs < ActiveRecord::Migration[6.0] # rubocop:todo Style/Documentation
  def change
    create_table :casa_orgs do |t|
      t.string :name

      t.timestamps
    end
  end
end
