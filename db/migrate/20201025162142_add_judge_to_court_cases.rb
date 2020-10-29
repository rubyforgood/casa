class AddJudgeToCourtCases < ActiveRecord::Migration[6.0]
  def change
    add_reference :casa_cases, :judge, null: true
  end
end
