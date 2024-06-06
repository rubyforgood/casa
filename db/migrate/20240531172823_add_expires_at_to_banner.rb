class AddExpiresAtToBanner < ActiveRecord::Migration[7.1]
  def change
    add_column :banners, :expires_at, :datetime, null: true
  end
end
