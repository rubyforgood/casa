require "rails_helper"

RSpec.describe SupervisorVolunteer do
  let(:casa_org_1) { build(:casa_org) }
  let(:casa_org_2) { build(:casa_org) }
  let(:volunteer_1) { build(:volunteer, casa_org: casa_org_1) }
  let(:supervisor_1) { create(:supervisor, casa_org: casa_org_1) }
  let(:supervisor_2) { create(:supervisor, casa_org: casa_org_1) }

  it "assigns a volunteer to a supervisor" do
    supervisor_1.volunteers << volunteer_1
    expect(volunteer_1.supervisor).to eq(supervisor_1)
  end

  it "only allow 1 supervisor per volunteer" do
    supervisor_1.volunteers << volunteer_1
    supervisor_1.save
    expect { supervisor_2.volunteers << volunteer_1 }.to raise_error(StandardError)
  end

  it "does not allow a volunteer to be double assigned" do
    expect {
      supervisor_1.volunteers << volunteer_1
      supervisor_1.volunteers << volunteer_1
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "requires supervisor and volunteer belong to same casa_org" do
    supervisor_volunteer = supervisor_1.supervisor_volunteers.new(volunteer: volunteer_1)
    expect { volunteer_1.update(casa_org: casa_org_2) }.to change(supervisor_volunteer, :valid?).to(false)
  end
end
