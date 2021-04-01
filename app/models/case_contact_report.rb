class CaseContactReport
  attr_reader :case_contacts

  def initialize(args = {})
    @case_contacts = filtered_case_contacts(args)
  end

  def to_csv
    case_contacts_for_csv = @case_contacts
    CaseContactsExportCsvService.new(case_contacts_for_csv).perform
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
  end
end
