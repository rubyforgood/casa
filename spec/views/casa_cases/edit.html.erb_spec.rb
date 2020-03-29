require 'rails_helper'

RSpec.describe "casa_cases/edit", type: :view do
  before(:each) do
    @casa_case = assign(:casa_case, CasaCase.create!(
      case_number: "MyString",
      teen_program_eligible: false
    ))
  end

  it "renders the edit casa_case form" do
    render

    assert_select "form[action=?][method=?]", casa_case_path(@casa_case), "post" do

      assert_select "input[name=?]", "casa_case[case_number]"

      assert_select "input[name=?]", "casa_case[teen_program_eligible]"
    end
  end
end
