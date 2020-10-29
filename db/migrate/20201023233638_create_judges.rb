class CreateJudges < ActiveRecord::Migration[6.0]
  def change
    create_table :judges do |t|
      t.references :casa_org, null: false, foreign_key: true

      t.timestamps
    end
  end
end
