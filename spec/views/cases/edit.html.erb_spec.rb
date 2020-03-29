require 'rails_helper'

RSpec.describe "cases/edit", type: :view do
  before(:each) do
    @case = assign(:case, Case.create!(
      case_number: "MyString",
      teen_program_eligible: false
    ))
  end

  it "renders the edit case form" do
    render

    assert_select "form[action=?][method=?]", case_path(@case), "post" do

      assert_select "input[name=?]", "case[case_number]"

      assert_select "input[name=?]", "case[teen_program_eligible]"
    end
  end
end
