class AddForeignKeyConstraintsToCaseEmancipationJoinTable < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :casa_cases_emancipation_options, :casa_cases
    add_foreign_key :casa_cases_emancipation_options, :emancipation_options
  end
end
