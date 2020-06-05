class CaseContactReport
  attr_reader :case_contacts

  def initialize(args = {})
    if args[:start_date] && args[:end_date]
      @case_contacts = CaseContact.occurred_between(args[:start_date], args[:end_date])
    else
      @case_contacts = CaseContact.all
    end
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << column_headers.map(&:titleize)

      @case_contacts.includes(:casa_case, creator: :supervisor).decorate.each do |case_contact|
        csv << generate_row(case_contact)
      end
    end
  end

  def column_headers
    # Note: these header labels are for stakeholders and do not match the
    # Rails DB names in all cases, e.g. added_to_system_at header is case_contact.created_at
    %w[internal_contact_number duration_minutes contact_types contact_made
       contact_medium occurred_at added_to_system_at miles_driven wants_driving_reimbursement
       casa_case_number volunteer_email volunteer_name supervisor_name]
  end

  def generate_row(case_contact)
    row_data = []

    row_data << case_contact_fields(case_contact)
    row_data << casa_case_fields(case_contact.casa_case)
    row_data << volunteer_fields(case_contact.creator)
    row_data << supervisor_fields(case_contact.creator&.supervisor)

    row_data.flatten
  end

  private

  # @param case_contact [CaseContact]
  def case_contact_fields(case_contact)
    [
      case_contact&.id,
      case_contact&.duration_minutes,
      case_contact&.contact_types,
      case_contact&.contact_made,
      case_contact&.medium_type,
      case_contact&.occurred_at&.strftime("%B %e, %Y"),
      case_contact&.created_at,
      case_contact&.miles_driven,
      case_contact&.want_driving_reimbursement
    ]
  end

  def casa_case_fields(casa_case)
    [
      casa_case&.case_number
    ]
  end

  def volunteer_fields(volunteer)
    [
      volunteer&.email,
      volunteer&.display_name
    ]
  end

  def supervisor_fields(supervisor)
    [
      supervisor&.display_name
    ]
  end
end
