require "rails_helper"

RSpec.describe SupervisorVolunteer do
  let(:volunteer_1) { create(:volunteer) }
  let(:supervisor_1) { create(:supervisor) }
  let(:supervisor_2) { create(:supervisor) }

  it "should only allow 1 supervisor per volunteer" do
    supervisor_1.volunteers << volunteer_1
    # supervisor_2.volunteers << volunteer_1
    
    # expect(supervisor_1.save!).to raise_error(StandardError)
    expect{supervisor_2.volunteers << volunteer_1}.to raise_error(StandardError)
  end
end