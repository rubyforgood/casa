class CaseContactReport
  attr_reader :case_contacts

  def initialize(args = {})
    @case_contacts = filtered_case_contacts(args)
  end

  def filtered_case_contacts(args)
    return CaseContact.all if args.empty?

    contact = CaseContact
    if args.has_key?(:start_date) && args[:end_date] # contact date range
      contact = contact.occurred_between(args[:start_date], args[:end_date])
    end
    contact = contact.where(creator_id: args[:creator_id]) if args.has_key?(:creator_id) # volunteer
    if args.has_key?(:supervisor_ids) # supervisor, as an array
      contact = contact.where(supervisors: args[:supervisor_ids])
    end
    contact = contact.where(contact_made: args[:contact_made]) if args.has_key?(:contact_made) # contact made, boolean
    if args.has_key?(:has_transitioned) # boolean, but also in the casa cases table
      contact = contact.joins(:casa_case).where("casa_cases.transition_aged_youth in (?)", args[:has_transitioned])
    end
    if args.has_key?(:want_driving_reimbursement)
      contact = contact.where(want_driving_reimbursement: args[:want_driving_reimbursement])
    end
    # This filter is not working properly, commenting it out for now
    # if args[:contact_types]
    #   args[:contact_types].each do |contact_type|
    #     contact = contact.where "contact_types @> ARRAY[?]::varchar[]", [contact_type]
    #   end
    # end

    contact
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << full_data(nil).keys.map(&:to_s).map(&:titleize)

      @case_contacts.includes(:casa_case, :creator).decorate.each do |case_contact|
        csv << full_data(case_contact).values
      end
    end
  end

  def full_data(case_contact)
    # Note: these header labels are for stakeholders and do not match the
    # Rails DB names in all cases, e.g. added_to_system_at header is case_contact.created_at
    {
      internal_contact_number: case_contact&.id,
      duration_minutes: case_contact&.report_duration_minutes,
      contact_types: case_contact&.report_contact_types,
      contact_made: case_contact&.report_contact_made,
      contact_medium: case_contact&.medium_type,
      occurred_at: case_contact&.occurred_at&.strftime("%B %e, %Y"),
      added_to_system_at: case_contact&.created_at,
      miles_driven: case_contact&.miles_driven,
      wants_driving_reimbursement: case_contact&.want_driving_reimbursement,
      casa_case_number: case_contact&.casa_case&.case_number,
      creator_email: case_contact&.creator&.email,
      creator_name: case_contact&.creator&.display_name,
      supervisor_name: case_contact&.creator&.supervisor&.display_name,
      case_contact_notes: case_contact&.notes
    }
  end
end
