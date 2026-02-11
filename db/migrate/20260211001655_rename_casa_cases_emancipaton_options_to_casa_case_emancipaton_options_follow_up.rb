class RenameCasaCasesEmancipatonOptionsToCasaCaseEmancipatonOptionsFollowUp < ActiveRecord::Migration[7.2]
  def change
    validate_foreign_key "casa_case_emancipation_options", "casa_cases", validate: false
    validate_foreign_key "casa_case_emancipation_options", "emancipation_options", validate: false

    drop_table :casa_cases_emancipation_options
  end
end
