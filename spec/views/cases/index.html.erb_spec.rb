require 'rails_helper'

RSpec.describe "cases/index", type: :view do
  before(:each) do
    assign(:cases, [
      Case.create!(
        case_number: "Case Number",
        teen_program_eligible: false
      ),
      Case.create!(
        case_number: "Case Number",
        teen_program_eligible: false
      )
    ])
  end

  it "renders a list of cases" do
    render
    assert_select "tr>td", text: "Case Number".to_s, count: 2
    assert_select "tr>td", text: false.to_s, count: 2
  end
end
