require "rails_helper"

RSpec.describe CaseContactContactType, type: :model do
  it "does not allow adding the same contact type twice to a case contact" do
    expect {
      case_contact = create(:case_contact)
      contact_type = create(:contact_type)

      case_contact.contact_types << contact_type
      case_contact.contact_types << contact_type
    }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
