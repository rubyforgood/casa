class ChangeCasaCaseTeenToRequired < ActiveRecord::Migration[6.0]
  def change
    change_column :casa_cases, :teen_program_eligible, :boolean, null: false, default: false
  end
end
# rubocop:enable Style/Documentation
