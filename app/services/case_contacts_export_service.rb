class CaseContactsExportService
  attr_accessor :case_contacts, :filtered_columns

  # Note: these header labels are for stakeholders and do not match the Rails DB names in all cases.
  # They are methods of the format report_LABEL on the CaseContactDecorator.
  DATA_COLUMNS = %w[
    internal_contact_number
    duration_minutes
    contact_types
    contact_made
    contact_medium
    occurred_at
    added_to_system_at
    miles_driven
    wants_driving_reimbursement
    casa_case_number
    creator_email
    creator_name
    supervisor_name
    case_contact_notes
  ]

  def initialize(case_contacts, filtered_columns = nil)
    self.filtered_columns = filtered_columns || DATA_COLUMNS.map(&:to_sym)

    self.case_contacts = case_contacts.preload({creator: :supervisor}, :contact_types, :casa_case)
  end

  def values_for_export(case_contact, filtered_columns = nil)
    hash = {}
    DATA_COLUMNS.each do |key|
      hash[key.to_sym] = value_for_key(case_contact, key)
    end
    hash.slice(*filtered_columns) if filtered_columns
    hash.values
  end

  # Only need to override keys that are database column names AND need change from raw database value
  def value_for_key(case_contact, key)
    case_contact.decorate.send("report_#{key}".to_sym)
  end
end
