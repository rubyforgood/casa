require 'rails_helper'

RSpec.describe "case_contacts/show", type: :view do
  before(:each) do
    @case_contact = assign(:case_contact, CaseContact.create!(
      user: nil,
      casa_case: nil,
      contact_type: "Contact Type",
      other_type_text: "Other Type Text",
      duration_minutes: 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Contact Type/)
    expect(rendered).to match(/Other Type Text/)
    expect(rendered).to match(/2/)
  end
end
