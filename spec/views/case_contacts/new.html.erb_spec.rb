require 'rails_helper'

RSpec.describe "case_contacts/new", type: :view do
  before(:each) do
    assign(:case_contact, CaseContact.new(
      user: nil,
      casa_case: nil,
      contact_type: "MyString",
      other_type_text: "MyString",
      duration_minutes: 1
    ))
  end

  it "renders new case_contact form" do
    render

    assert_select "form[action=?][method=?]", case_contacts_path, "post" do

      assert_select "input[name=?]", "case_contact[user_id]"

      assert_select "input[name=?]", "case_contact[casa_case_id]"

      assert_select "input[name=?]", "case_contact[contact_type]"

      assert_select "input[name=?]", "case_contact[other_type_text]"

      assert_select "input[name=?]", "case_contact[duration_minutes]"
    end
  end
end
