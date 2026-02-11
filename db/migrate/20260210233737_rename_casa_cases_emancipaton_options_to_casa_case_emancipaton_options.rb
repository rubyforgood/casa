class RenameCasaCasesEmancipatonOptionsToCasaCaseEmancipatonOptions < ActiveRecord::Migration[7.2]
  def change
    reversible do |dir|
      dir.up do
        create_table "casa_case_emancipation_options" do |t|
          t.bigint "casa_case_id", null: false
          t.bigint "emancipation_option_id", null: false
          t.datetime "created_at", null: false
          t.datetime "updated_at", null: false
          t.index ["casa_case_id", "emancipation_option_id"], name: "index_case_options_on_case_id_and_option_id", unique: true
        end

        add_foreign_key "casa_case_emancipation_options", "casa_cases", validate: false
        add_foreign_key "casa_case_emancipation_options", "emancipation_options", validate: false

        safety_assured do
          execute <<-SQL
            INSERT INTO casa_case_emancipation_options (casa_case_id, emancipation_option_id, created_at, updated_at) SELECT casa_case_id, emancipation_option_id, created_at, updated_at FROM casa_cases_emancipation_options;
          SQL
        end
      end

      dir.down do
        remove_foreign_key "casa_case_emancipation_options", "casa_cases", validate: false
        remove_foreign_key "casa_case_emancipation_options", "emancipation_options", validate: false

        drop_table :casa_case_emancipation_options
      end
    end
  end
end
