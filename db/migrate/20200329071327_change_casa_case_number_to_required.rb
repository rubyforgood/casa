class ChangeCasaCaseNumberToRequired < ActiveRecord::Migration[6.0]
  def change
    change_column :casa_cases, :case_number, :string, null: false
  end
end
# rubocop:enable Style/Documentation
