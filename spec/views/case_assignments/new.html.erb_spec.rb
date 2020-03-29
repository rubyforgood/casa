require 'rails_helper'

RSpec.describe "case_assignments/new", type: :view do
  before(:each) do
    assign(:case_assignment, CaseAssignment.new(
      volunteer_id: 1,
      casa_case_id: "",
      is_active: false
    ))
  end

  it "renders new case_assignment form" do
    render

    assert_select "form[action=?][method=?]", case_assignments_path, "post" do

      assert_select "input[name=?]", "case_assignment[volunteer_id]"

      assert_select "input[name=?]", "case_assignment[casa_case_id]"

      assert_select "input[name=?]", "case_assignment[is_active]"
    end
  end
end
