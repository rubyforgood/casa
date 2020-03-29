require 'rails_helper'

RSpec.describe "case_contacts/edit", type: :view do
  before(:each) do
    @case_contact = assign(:case_contact, CaseContact.create!(
      user: nil,
      casa_case: nil,
      contact_type: "MyString",
      other_type_text: "MyString",
      duration_minutes: 1
    ))
  end

  it "renders the edit case_contact form" do
    render

    assert_select "form[action=?][method=?]", case_contact_path(@case_contact), "post" do

      assert_select "input[name=?]", "case_contact[user_id]"

      assert_select "input[name=?]", "case_contact[casa_case_id]"

      assert_select "input[name=?]", "case_contact[contact_type]"

      assert_select "input[name=?]", "case_contact[other_type_text]"

      assert_select "input[name=?]", "case_contact[duration_minutes]"
    end
  end
end
