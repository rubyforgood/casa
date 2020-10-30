class AddHearingTypeToCourtCases < ActiveRecord::Migration[6.0]
  def change
    add_reference :casa_cases, :hearing_type, null: true
  end
end
