require 'rails_helper'

RSpec.describe "case_updates/index", type: :view do
  before(:each) do
    assign(:case_updates, [
      CaseUpdate.create!(
        user: nil,
        casa_case: nil,
        update_type: "Update Type",
        other_type_text: "Other Type Text"
      ),
      CaseUpdate.create!(
        user: nil,
        casa_case: nil,
        update_type: "Update Type",
        other_type_text: "Other Type Text"
      )
    ])
  end

  it "renders a list of case_updates" do
    render
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: "Update Type".to_s, count: 2
    assert_select "tr>td", text: "Other Type Text".to_s, count: 2
  end
end
