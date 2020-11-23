class AddNameToJudge < ActiveRecord::Migration[6.0]
  def change
    add_column :judges, :name, :string
  end
end
