class AddVolunteerReferenceToCasaCases < ActiveRecord::Migration[6.0]
  def change
    add_reference :casa_cases, :volunteer
  end
end
