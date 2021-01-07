class RecreateJoinTableCasaCasesEmancipationCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :casa_cases_emancipation_options do |t|
      t.references :casa_case, null: false, foreign_key: true
      t.references :emancipation_option, null: false, foreign_key: true, index: {name: "index_case_emancipation_options_on_emancipation_option_id"}

      t.timestamps
    end
  end
end
