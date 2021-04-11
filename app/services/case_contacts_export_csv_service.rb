require "csv"

class CaseContactsExportCsvService
  attr_reader :case_contacts

  def initialize(case_contacts)
    @case_contacts = case_contacts.preload({creator: :supervisor}, :contact_types, :casa_case)
  end

  def perform
    CSV.generate(headers: true) do |csv|
      csv << full_data.keys.map(&:to_s).map(&:titleize)
      if case_contacts.present?
        case_contacts.decorate.each do |case_contact|
          csv << full_data(case_contact).values
        end
      end
    end
  end

  private

  def full_data(case_contact = nil)
    # Note: these header labels are for stakeholders and do not match the
    # Rails DB names in all cases, e.g. added_to_system_at header is case_contact.created_at
    {
      internal_contact_number: case_contact&.id,
      duration_minutes: case_contact&.report_duration_minutes,
      contact_types: case_contact&.report_contact_types,
      contact_made: case_contact&.report_contact_made,
      contact_medium: case_contact&.medium_type,
      occurred_at: I18n.l(case_contact&.occurred_at, format: :full, default: nil),
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
