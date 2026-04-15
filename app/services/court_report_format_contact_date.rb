# frozen_string_literal: true

class CourtReportFormatContactDate
  CONTACT_SUCCESSFUL_SUFFIX = ''
  CONTACT_UNSUCCESSFUL_SUFFIX = '*'

  def initialize(case_contact)
    @case_contact = case_contact
  end

  def format
    I18n.l(
      @case_contact.occurred_at,
      format: :short_date,
      default: nil
    ).concat(contact_made_suffix)
  end

  def format_long
    I18n.l(@case_contact.occurred_at, format: :long_date, default: nil)
  end

  private

  attr_reader :case_contact

  def contact_made_suffix
    @case_contact.contact_made ? CONTACT_SUCCESSFUL_SUFFIX : CONTACT_UNSUCCESSFUL_SUFFIX
  end
end
