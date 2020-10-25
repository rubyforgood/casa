class AddActiveToJudge < ActiveRecord::Migration[6.0]
  def change
    add_column :judges, :active, :boolean, default: true
  end
end
