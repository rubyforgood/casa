class CreateFollowups < ActiveRecord::Migration[6.1]
  def change
    create_table :followups do |t|
      t.belongs_to :case_contact
      t.belongs_to :creator, foreign_key: {to_table: :users}
      t.integer :status, default: 0, not_null: true

      t.timestamps
    end
  end
end
