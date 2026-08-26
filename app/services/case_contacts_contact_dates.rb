class CaseContactsContactDates
  def initialize(case_contact_contact_types)
    @case_contact_contact_types = case_contact_contact_types
  end

  def contact_dates_details
    contact_types = @case_contact_contact_types
      .map(&:contact_type)
      .uniq
      .sort_by { |contact_type| [contact_type.contact_type_group.name, contact_type.name] }

    contact_types.map do |contact_type|
      case_contacts = case_contacts_for_type(contact_type)

      {
        name: "Names of persons involved, starting with the child's name",
        type: contact_type.name,
        dates: order_and_format(case_contacts),
        dates_by_medium_type: case_contacts.group_by(&:medium_type).transform_values { |vals| order_and_format(vals) }
      }
    end
  end

  private

  def case_contacts_for_type(contact_type)
    @case_contact_contact_types
      .select { |ccct| ccct.contact_type_id == contact_type.id }
      .map(&:case_contact)
  end

  def format_dates(case_contacts)
    case_contacts.map { |case_contact| CourtReportFormatContactDate.new(case_contact).format }.join(", ")
  end

  def chron_sort(case_contacts)
    case_contacts.sort_by { |case_contact| case_contact.occurred_at }
  end

  def order_and_format(case_contacts)
    case_contacts.then { chron_sort it }.then { format_dates it }
  end
end
