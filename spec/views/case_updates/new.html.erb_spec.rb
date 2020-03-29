require 'rails_helper'

RSpec.describe "case_updates/new", type: :view do
  before(:each) do
    assign(:case_update, CaseUpdate.new(
      user: nil,
      casa_case: nil,
      update_type: "MyString",
      other_type_text: "MyString"
    ))
  end

  it "renders new case_update form" do
    render

    assert_select "form[action=?][method=?]", case_updates_path, "post" do

      assert_select "input[name=?]", "case_update[user_id]"

      assert_select "input[name=?]", "case_update[casa_case_id]"

      assert_select "input[name=?]", "case_update[update_type]"

      assert_select "input[name=?]", "case_update[other_type_text]"
    end
  end
end
