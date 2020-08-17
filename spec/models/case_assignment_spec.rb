require "rails_helper"

RSpec.describe CaseAssignment do
  it "should only allow active volunteers to be assigned" do
    casa_case = create(:casa_case)
    volunteer = create(:volunteer)
    inactive = create(:volunteer, :inactive)
    supervisor = create(:supervisor)

    expect(casa_case.case_assignments.new(volunteer: volunteer)).to be_valid
    casa_case.reload

    expect(casa_case.case_assignments.new(volunteer: inactive)).to be_invalid
    casa_case.reload

    expect(casa_case.case_assignments.new(volunteer: supervisor)).to be_invalid
  end
end
