class CreateContactType < ActiveRecord::Migration[6.0]
  def change
    create_table :contact_type_groups do |t|
      t.references :casa_org, null: false
      t.string :name, null: false
      t.timestamps
    end

    create_table :contact_types do |t|
      t.references :contact_type_group, null: false
      t.string :name, null: false
      t.timestamps
    end
  end
end
