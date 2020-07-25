require "rails_helper"

describe "case_contacts/edit" do

  it "is listing all the contact methods from the model" do
    case_contact = create(:case_contact)
    assign :case_contact, case_contact
    assign :casa_cases, [case_contact.casa_case]

    contact_types = CaseContact::CONTACT_TYPES.each_with_index do |contact_type, index|
      render template: "case_contacts/edit"
      expect(rendered).to include(contact_type)
    end
  end
end
