class RemoveTransitionAgedYouthFromCasaCase < ActiveRecord::Migration[6.1]
  def change
    remove_column :casa_cases, :transition_aged_youth, :boolean
  end
end
