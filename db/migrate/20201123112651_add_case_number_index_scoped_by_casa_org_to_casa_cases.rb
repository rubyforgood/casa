class AddCaseNumberIndexScopedByCasaOrgToCasaCases < ActiveRecord::Migration[6.0]
  def change
    add_index :casa_cases, [:case_number, :casa_org_id], unique: true
  end
end
