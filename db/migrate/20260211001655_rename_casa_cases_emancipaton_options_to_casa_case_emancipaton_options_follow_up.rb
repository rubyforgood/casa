class RenameCasaCasesEmancipatonOptionsToCasaCaseEmancipatonOptionsFollowUp < ActiveRecord::Migration[7.2]
  def up
    validate_foreign_key "casa_case_emancipation_options", "casa_cases"
    validate_foreign_key "casa_case_emancipation_options", "emancipation_options"

    drop_table :casa_cases_emancipation_options
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
