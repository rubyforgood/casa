require "csv"
require 'case_contacts_export_data_columns'

class CaseContactsExportCsvService
  attr_reader :case_contacts, :filtered_columns
  include CaseContactsExportDataColumns

  def initialize(case_contacts, filtered_columns = nil)
    @filtered_columns = filtered_columns || CaseContactsExportDataColumns.data_columns.keys

    @case_contacts = case_contacts.preload({creator: :supervisor}, :contact_types, :casa_case)
  end

  def perform
    CSV.generate(headers: true) do |csv|
      csv << filtered_columns.map(&:to_s).map(&:titleize)
      if case_contacts.present?
        case_contacts.decorate.each do |case_contact|
          csv << CaseContactsExportDataColumns.data_columns(case_contact).slice(*filtered_columns).values
        end
      end
    end
  end

end
