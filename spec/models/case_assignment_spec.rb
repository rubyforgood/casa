require "rails_helper"

RSpec.describe CaseAssignment do
  let(:casa_case_1) { create(:casa_case) }
  let(:volunteer_1) { create(:volunteer) }
  let(:inactive) { create(:volunteer, :inactive) }
  let(:supervisor) { create(:supervisor) }
  let(:casa_case_2) { create(:casa_case) }
  let(:volunteer_2) { create(:volunteer) }

  it "should only allow active volunteers to be assigned" do
    expect(casa_case_1.case_assignments.new(volunteer: volunteer_1)).to be_valid
    casa_case_1.reload

    expect(casa_case_1.case_assignments.new(volunteer: inactive)).to be_invalid
    casa_case_1.reload

    expect(casa_case_1.case_assignments.new(volunteer: supervisor)).to be_invalid
  end

  it "allows two volunteers to be assigned to the same case" do
    casa_case_1.volunteers << volunteer_1
    casa_case_1.volunteers << volunteer_2
    casa_case_1.save!

    expect(volunteer_1.casa_cases).to eq([casa_case_1])
    expect(volunteer_2.casa_cases).to eq([casa_case_1])
  end

  it "allows volunteer to be assigned to multiple cases" do
    volunteer_1.casa_cases << casa_case_1
    volunteer_1.casa_cases << casa_case_2
    volunteer_1.save!

    expect(casa_case_1.reload.volunteers).to eq([volunteer_1])
    expect(casa_case_2.reload.volunteers).to eq([volunteer_1])
  end
end
