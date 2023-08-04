class CreateCaseGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :case_groups do |t|
      t.references :casa_org, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
