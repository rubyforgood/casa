require 'rails_helper'

RSpec.describe "supervisor_volunteers/edit", type: :view do
  before(:each) do
    @supervisor_volunteer = assign(:supervisor_volunteer, SupervisorVolunteer.create!(
      volunteer_id: "",
      supervisor_id: ""
    ))
  end

  it "renders the edit supervisor_volunteer form" do
    render

    assert_select "form[action=?][method=?]", supervisor_volunteer_path(@supervisor_volunteer), "post" do

      assert_select "input[name=?]", "supervisor_volunteer[volunteer_id]"

      assert_select "input[name=?]", "supervisor_volunteer[supervisor_id]"
    end
  end
end
