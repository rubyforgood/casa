require "csv"

class FollowupExportCsvService
  def initialize(casa_org)
    @casa_org = casa_org
  end

  def perform
    # Call to includes will run 5 selects, one for each association
    # regardless of how many followup records that exist in the
    # export. This prevents an N+1 query for getting the case_number
    # and volunteer display_name.
    followups = @casa_org.followups.includes(followupable: { casa_case: :volunteers })

    CSV.generate(headers: true, encoding: 'UTF-8') do |csv|
      # generate the header row
      csv << full_data.keys.map(&:to_s).map(&:titleize)
      # data rows
      followups.each do |followup|
        csv << full_data(followup).values
      end
    end
  end

  private

  def full_data(followup = nil)
    followupable_casa_case = followup&.associated_casa_case
    {
      case_number: followupable_casa_case&.case_number,
      "volunteer_name(s)": followupable_casa_case&.volunteers&.sort_by(&:display_name)&.map(&:display_name)&.join(" and "),
      note_creator_name: followup&.creator&.display_name,
      note: followup&.note
    }
  end
end
