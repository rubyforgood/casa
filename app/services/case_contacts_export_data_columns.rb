module CaseContactsExportDataColumns
  def self.data_columns(case_contact = nil)

    data = {
      internal_contact_number: case_contact&.id,
      duration_minutes: case_contact&.report_duration_minutes,
      contact_types: case_contact&.report_contact_types,
      contact_made: case_contact&.report_contact_made,
      contact_medium: case_contact&.medium_type,
      occurred_at: I18n.l(case_contact&.occurred_at, format: :full, default: nil),
      added_to_system_at: case_contact&.created_at&.strftime('%Y-%m-%d %H:%M:%S %Z'),
      miles_driven: case_contact&.miles_driven,
      wants_driving_reimbursement: case_contact&.want_driving_reimbursement,
      casa_case_number: case_contact&.casa_case&.case_number,
      creator_email: case_contact&.creator&.email,
      creator_name: case_contact&.creator&.display_name,
      supervisor_name: case_contact&.creator&.supervisor&.display_name,
      case_contact_notes: case_contact&.notes
    }

    data
  end

end