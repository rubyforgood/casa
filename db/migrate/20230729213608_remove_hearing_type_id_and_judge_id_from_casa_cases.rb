class RemoveHearingTypeIdAndJudgeIdFromCasaCases < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :casa_cases, :hearing_type_id }
    safety_assured { remove_column :casa_cases, :judge_id }
  end
end
