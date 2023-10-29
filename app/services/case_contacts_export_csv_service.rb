require "csv"

class CaseContactsExportCsvService < CaseContactsExportService
  def perform
    CSV.generate(headers: true) do |csv|
      csv << filtered_columns.map(&:to_s).map(&:titleize)
      if case_contacts.present?
        case_contacts.decorate.each do |case_contact|
          csv << values_for_export(case_contact, filtered_columns)
        end
      end
    end
  end
end
