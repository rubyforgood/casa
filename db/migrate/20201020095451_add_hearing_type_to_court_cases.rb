class AddHearingTypeToCourtCases < ActiveRecord::Migration[6.0]
  def change
    add_reference :casa_cases, :hearing_type
  end
end
