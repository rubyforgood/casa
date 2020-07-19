class ChangeTeenProgramToTransitionAgedYouth < ActiveRecord::Migration[6.0]
  def change
    rename_column :casa_cases, :teen_program_eligible, :transition_aged_youth
  end
end
