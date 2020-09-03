require "rails_helper"

RSpec.describe SupervisorVolunteer do
  let(:volunteer_1) { create(:volunteer) }
  let(:supervisor_1) { create(:supervisor) }
  let(:supervisor_2) { create(:supervisor) }

  it "should assign a volunteer to a supervisor" do
    supervisor_1.volunteers << volunteer_1
    expect(volunteer_1.supervisor).to eq(supervisor_1)
  end

  it "should only allow 1 supervisor per volunteer" do
    supervisor_1.volunteers << volunteer_1
        
    expect{ supervisor_2.volunteers << volunteer_1 }.to raise_error(StandardError)
  end
end