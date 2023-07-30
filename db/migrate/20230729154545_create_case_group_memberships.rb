class CreateCaseGroupMemberships < ActiveRecord::Migration[7.0]
  def change
    create_table :case_group_memberships do |t|
      t.references :case_group, null: false, foreign_key: true
      t.references :casa_case, null: false, foreign_key: true

      t.timestamps
    end
  end
end
