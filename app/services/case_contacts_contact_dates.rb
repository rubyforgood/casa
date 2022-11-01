class CaseContactsContactDates
  def initialize(case_contact_contact_types)
    @case_contact_contact_types = case_contact_contact_types
  end

  def contact_dates_details
    contact_type_names = @case_contact_contact_types.map(&:contact_type).map(&:name).uniq # .sort # TODO sort after refactor
    contact_type_names.map do |contact_type_name|
      case_contacts = case_contacts_for_type(contact_type_name)

      {
        name: "Names of persons involved, starting with the child's name",
        type: contact_type_name,
        dates: order_and_format(case_contacts),
        dates_by_medium_type: case_contacts.group_by(&:medium_type).transform_values { |vals| order_and_format(vals) }
      }
    end
  end

  private

  def case_contacts_for_type(contact_type_name)
    @case_contact_contact_types
      .select { |ccct| ccct.contact_type.name == contact_type_name }
      .map(&:case_contact)
  end

  def format_dates(case_contacts)
    case_contacts.map { |case_contact| CourtReportFormatContactDate.new(case_contact).format }.join(", ")
  end

  def chron_sort(case_contacts)
    case_contacts.sort_by { |case_contact| case_contact.occurred_at }
  end

  def order_and_format(case_contacts)
    case_contacts.then { chron_sort _1 }.then { format_dates _1 }
  end
end
