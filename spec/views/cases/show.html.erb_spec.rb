require 'rails_helper'

RSpec.describe "cases/show", type: :view do
  before(:each) do
    @case = assign(:case, Case.create!(
      case_number: "Case Number",
      teen_program_eligible: false
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Case Number/)
    expect(rendered).to match(/false/)
  end
end
