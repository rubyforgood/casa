class CourtReportFormatContactDate
  CONTACT_SUCCESSFUL_PREFIX = "*"

  def initialize(case_contact)
    @case_contact = case_contact
  end

  def format
    I18n.l(@case_contact.occurred_at, format: :short_date, default: nil).concat(@case_contact.contact_made ? "" : CONTACT_SUCCESSFUL_PREFIX)
  end
end
