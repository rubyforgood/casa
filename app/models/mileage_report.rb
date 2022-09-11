class MileageReport
  attr_reader :case_contacts

  def initialize(org_id)
    @case_contacts = CaseContact.casa_org(org_id).where(
      want_driving_reimbursement: true,
      reimbursement_complete: false
    ).where("case_contacts.created_at > ?", 1.year.ago)
  end

  def to_csv
    MileageExportCsvService.new(@case_contacts).perform
  end
end
