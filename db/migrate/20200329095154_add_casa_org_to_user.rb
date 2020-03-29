class AddCasaOrgToUser < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :casa_org, foreign_key: true, null: false
  end
end
