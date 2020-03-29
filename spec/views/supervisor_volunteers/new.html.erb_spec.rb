require 'rails_helper'

RSpec.describe "supervisor_volunteers/new", type: :view do
  before(:each) do
    assign(:supervisor_volunteer, SupervisorVolunteer.new(
      volunteer_user_id: "",
      supervisor_user_id: ""
    ))
  end

  it "renders new supervisor_volunteer form" do
    render

    assert_select "form[action=?][method=?]", supervisor_volunteers_path, "post" do

      assert_select "input[name=?]", "supervisor_volunteer[volunteer_user_id]"

      assert_select "input[name=?]", "supervisor_volunteer[supervisor_user_id]"
    end
  end
end
