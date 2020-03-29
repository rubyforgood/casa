require 'rails_helper'

RSpec.describe "supervisor_volunteers/show", type: :view do
  before(:each) do
    @supervisor_volunteer = assign(:supervisor_volunteer, SupervisorVolunteer.create!(
      volunteer_id: "",
      supervisor_id: ""
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
