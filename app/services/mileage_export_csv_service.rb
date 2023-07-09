require "csv"

class MileageExportCsvService
  def initialize(case_contacts)
    @case_contacts = case_contacts.preload({creator: :supervisor}, :contact_types, :casa_case)
  end

  def perform
    CSV.generate(headers: true) do |csv|
      csv << full_data.keys.map(&:to_s).map(&:titleize)
      if @case_contacts.present?
        @case_contacts.decorate.each do |case_contact|
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
      contact_types: case_contact&.report_contact_types,
      occurred_at: I18n.l(case_contact&.occurred_at, format: :full, default: nil),
      miles_driven: case_contact&.miles_driven,
      casa_case_number: case_contact&.casa_case&.case_number,
      creator_name: case_contact&.creator&.display_name,
      supervisor_name: case_contact&.creator&.supervisor&.display_name,
      volunteer_address: case_contact&.creator&.address&.content,
      reimbursed: case_contact&.reimbursement_complete
    }
  end
end
