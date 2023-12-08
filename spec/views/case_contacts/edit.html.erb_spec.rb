require "rails_helper"

RSpec.describe "case_contacts/edit", type: :view do
  before do
    user = build_stubbed(:volunteer)
    casa_org = user.casa_org
    role = user.role
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_role).and_return(role)
    allow(view).to receive(:current_organization).and_return(casa_org)
  end

  it "is listing all the contact methods from the model" do
    case_contact = build_stubbed(:case_contact)
    contact_type = build_stubbed(:contact_type, name: "In person")
    assign :case_contact, case_contact
    assign :casa_cases, [case_contact.casa_case]
    assign :selected_cases, [case_contact.casa_case]
    assign :contact_types, [contact_type]
    assign :current_organization_groups, [contact_type.contact_type_group]

    render template: "case_contacts/edit"
    expect(rendered).to include(contact_type.name)
  end

  it "displays occurred time in the occurred at form field" do
    case_contact = build_stubbed(:case_contact)
    case_contact.occurred_at = Time.zone.now - (3600 * 24)
    contact_type = build_stubbed(:contact_type, name: "In person")
    assign :case_contact, case_contact
    assign :casa_cases, [case_contact.casa_case]
    assign :selected_cases, [case_contact.casa_case]
    assign :contact_types, [contact_type]
    assign :current_organization_groups, [contact_type.contact_type_group]

    render template: "case_contacts/edit"
    expect(rendered).to include(case_contact.occurred_at.strftime("%Y-%m-%d"))
  end
end
