require 'rails_helper'

RSpec.describe "cases/new", type: :view do
  before(:each) do
    assign(:case, Case.new(
      case_number: "MyString",
      teen_program_eligible: false
    ))
  end

  it "renders new case form" do
    render

    assert_select "form[action=?][method=?]", cases_path, "post" do

      assert_select "input[name=?]", "case[case_number]"

      assert_select "input[name=?]", "case[teen_program_eligible]"
    end
  end
end
