class RemoveVolunteerIdFromCasaCase < ActiveRecord::Migration[6.0]
  def change
    remove_reference :casa_cases, :volunteer
  end
end
