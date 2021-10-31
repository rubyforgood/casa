class AddUniqueIndexOnCaseCaseNumber < ActiveRecord::Migration[6.0]
  def change
    add_index :casa_cases, :case_number, unique: true
  end
end
# rubocop:enable Style/Documentation
