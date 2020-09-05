require "rails_helper"

describe "case_contacts/edit" do
  before do
    user = build_stubbed(:volunteer)
    allow(view).to receive(:current_user).and_return(user)
  end

  it "is listing all the contact methods from the model" do
    case_contact = create(:case_contact)
    assign :case_contact, case_contact
    assign :casa_cases, [case_contact.casa_case]
    assign :selected_cases, [case_contact.casa_case]

    CaseContact::CONTACT_TYPES.each_with_index do |contact_type, index|
      render template: "case_contacts/edit"
      expect(rendered).to include(contact_type)
    end
  end

  it "displays occurred time in the occurred at form field" do
    case_contact = create(:case_contact)
    case_contact.occurred_at = Time.zone.now - (3600 * 24)
    assign :case_contact, case_contact
    assign :casa_cases, [case_contact.casa_case]
    assign :selected_cases, [case_contact.casa_case]

    render template: "case_contacts/edit"
    expect(rendered).to include(case_contact.occurred_at.strftime("%Y-%m-%d"))
  end

  it "properly titleizes DSS Worker" do
    case_contact = create(:case_contact)
    assign :case_contact, case_contact
    assign :casa_cases, [case_contact.casa_case]
    assign :selected_cases, [case_contact.casa_case]

    render template: "case_contacts/edit"
    expect(rendered).to include("DSS") 
  end

end
