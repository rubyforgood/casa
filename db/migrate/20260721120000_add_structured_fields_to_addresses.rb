class AddStructuredFieldsToAddresses < ActiveRecord::Migration[8.0]
  # Structured mailing address (line 1 / line 2 / city / state / zip) replacing the single
  # free-text `content` string in the UI. `content` is kept as the composed, human-readable
  # one-line value the rest of the app reads (reimbursement table, mileage export, case-contact
  # prefill); Address#compose_content keeps it in sync. Adding nullable columns is safe.
  def change
    add_column :addresses, :line_1, :string
    add_column :addresses, :line_2, :string
    add_column :addresses, :city, :string
    add_column :addresses, :state, :string
    add_column :addresses, :zip, :string
  end
end
