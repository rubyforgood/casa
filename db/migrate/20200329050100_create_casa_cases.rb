class CreateCasaCases < ActiveRecord::Migration[6.0]
  def change
    create_table :casa_cases do |t|
      t.string :case_number
      t.boolean :teen_program_eligible

      t.timestamps
    end
  end
end
# rubocop:enable Style/Documentation
