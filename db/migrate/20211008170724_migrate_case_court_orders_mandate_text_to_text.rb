class MigrateCaseCourtOrdersMandateTextToText < ActiveRecord::Migration[6.1]
  def up
    execute "update case_court_orders set text=mandate_text"
  end
end
