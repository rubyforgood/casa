class CreateHearingTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :hearing_types do |t|
      t.references :casa_org, null: false
      t.string :name, null: false
      t.boolean :active, null: false, default: true
    end
  end
end
