class CaseContactsContactDates
  def initialize(case_contact_contact_types)
    @case_contact_contact_types = case_contact_contact_types
  end

  def contact_dates_details
    contact_type_names = @case_contact_contact_types.map(&:contact_type).map(&:name).uniq # .sort # TODO sort after refactor
    contact_type_names.map do |contact_type_name|
      {
        name: "Names of persons involved, starting with the child's name",
        type: contact_type_name,
        dates: @case_contact_contact_types.select { |ccct|
          ccct.contact_type.name == contact_type_name
        }.map(&:case_contact).sort_by { |case_contact|
          case_contact.occurred_at
        }.map { |case_contact|
          CourtReportFormatContactDate.new(case_contact).format
        }.join(", ")
      }
    end
  end
end
