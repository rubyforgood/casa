require 'rails_helper'

RSpec.describe CaseContactReport, type: :model do
  describe '#generate_headers' do
    it 'matches the length of row data' do
      case_contact = create(:case_contact)
      case_contact_report = described_class.new(case_contact)

      header_column_count = case_contact_report.column_headers.length
      data_column_count = case_contact_report.generate_row(case_contact).length

      expect(header_column_count).to eq data_column_count
    end
  end
end
