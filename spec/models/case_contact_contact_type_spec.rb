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

  it "sorts contact types alphabetically" do 
    case_contact = create(:case_contact)
    contact_type_groups = []
    contact_type = create(:contact_type)
    contact_type_B = create(:contact_type)
    contact_type_groups << contact_type
    contact_type_groups << contact_type_B 

    expect(contact_type_groups).to eq([contact_type, contact_type_B])
  end
end
