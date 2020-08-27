class AddCasaOrgToCasaCase < ActiveRecord::Migration[6.0]
  def change
    add_reference :casa_cases, :casa_org, null: false, foreign_key: true, index: true
  end
end
