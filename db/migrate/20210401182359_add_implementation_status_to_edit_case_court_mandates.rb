class AddImplementationStatusToEditCaseCourtMandates < ActiveRecord::Migration[6.1]
  def change
    add_column :case_court_mandates, :implementation_status, :integer
  end
end
