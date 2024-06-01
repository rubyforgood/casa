class CaseContactReport
  attr_reader :case_contacts, :columns

  def initialize(args = {})
    @columns = filtered_columns(args)
    @case_contacts = filtered_case_contacts(args)
  end

  def to_csv
    case_contacts_for_csv = @case_contacts
    CaseContactsExportCsvService.new(case_contacts_for_csv, columns).perform
  end

  private

  def filtered_case_contacts(args)
    CaseContact
      .supervisors(args[:supervisor_ids])
      .creators(args[:creator_ids])
      .casa_org(args[:casa_org_id])
      .occurred_between(args[:start_date], args[:end_date])
      .contact_made(args[:contact_made])
      .has_transitioned(args[:has_transitioned])
      .want_driving_reimbursement(args[:want_driving_reimbursement])
      .contact_type(args[:contact_type_ids])
      .contact_type_groups(args[:contact_type_group_ids])
      .with_casa_case(args[:casa_case_ids])
  end

  def filtered_columns(args)
    if args[:filtered_csv_cols].present?
      args[:filtered_csv_cols].select { |_key, value| value == "true" }.keys.map(&:to_sym)
    end
  end

  COLUMNS = [
    :internal_contact_number,
    :duration_minutes,
    :contact_types,
    :contact_made,
    :contact_medium,
    :occurred_at,
    :added_to_system_at,
    :miles_driven,
    :wants_driving_reimbursement,
    :casa_case_number,
    :creator_email,
    :creator_name,
    :supervisor_name,
    :case_contact_notes,
  ]

end
