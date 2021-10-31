class AddRoleToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :role, :string, null: false, default: "volunteer"
  end
end
# rubocop:enable Style/Documentation
