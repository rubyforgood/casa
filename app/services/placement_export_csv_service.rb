require "csv"

class PlacementExportCsvService
  attr_reader :placements

  def initialize(casa_org:)
    @casa_org = casa_org
  end

  def perform
    placements = fetch_placements

    CSV.generate(headers: true) do |csv|
      csv << full_data.keys.map(&:to_s).map(&:titleize)
      placements.decorate.each do |placement|
        csv << full_data(placement).values
      end
    end
  end

  private

  def full_data(placement = nil)
    {
      casa_org: placement&.id,
      casa_case_number: placement&.casa_case&.case_number,
      placement_type_id: placement&.placement_type_id,
      placement_started_at: placement&.placement_started_at,
      created_at: placement&.created_at,
      creator_name: placement&.creator&.display_name
    }
  end

  def fetch_placements
    @casa_org.placements
  end
end
