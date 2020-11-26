class RemoveCaseNumberIndexFromCasaCases < ActiveRecord::Migration[6.0]
  def change
    remove_index :casa_cases, column: :case_number, unique: true
  end
end
