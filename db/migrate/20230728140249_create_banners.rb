class CreateBanners < ActiveRecord::Migration[7.0]
  def change
    create_table :banners do |t|
      t.references :casa_org, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.boolean :active, default: false

      t.timestamps
    end
  end
end
