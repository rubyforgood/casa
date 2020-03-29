require 'rails_helper'

RSpec.describe "case_contacts/index", type: :view do
  before(:each) do
    assign(:case_contacts, [
      CaseContact.create!(
        user: nil,
        casa_case: nil,
        contact_type: "Contact Type",
        other_type_text: "Other Type Text",
        duration_minutes: 2
      ),
      CaseContact.create!(
        user: nil,
        casa_case: nil,
        contact_type: "Contact Type",
        other_type_text: "Other Type Text",
        duration_minutes: 2
      )
    ])
  end

  it "renders a list of case_contacts" do
    render
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: "Contact Type".to_s, count: 2
    assert_select "tr>td", text: "Other Type Text".to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
  end
end
