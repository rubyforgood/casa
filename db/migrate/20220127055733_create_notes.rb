class CreateNotes < ActiveRecord::Migration[6.1]
  def change
    create_table :notes do |t|
      t.string :content
      t.bigint :creator_id
      t.references :notable, polymorphic: true

      t.timestamps
    end
  end
end
