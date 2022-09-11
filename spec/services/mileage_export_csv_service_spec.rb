require "rails_helper"

RSpec.describe MileageExportCsvService do
  subject { described_class.new(case_contacts) }
  let(:case_contacts) { [case_contact] }
  let(:case_contact) { create(:case_contact) }
end
