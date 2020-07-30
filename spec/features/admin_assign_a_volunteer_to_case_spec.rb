require "rails_helper"

RSpec.describe "admin or supervisor assign and unassign a volunteer to case", type: :feature do
  let(:supervisor1) { create(:user, :supervisor) }
  let(:casa_case) { create(:casa_case) }

  before do
    sign_in supervisor1
    volunteer = create(:user, :volunteer)
    visit casa_case_path(casa_case.id)
    click_on "Edit Case Details"

    select volunteer.email, from: "case_assignment[volunteer_id]"

    click_on "Assign Volunteer"
  end

  it "when a volunteer assign to a case" do
    expect(casa_case.case_assignments.count).to eq 1

    unassign_button = page.find("input.btn-outline-danger")
    expect(unassign_button.value).to eq "Unassign Volunteer"

    assign_badge = page.find("span.badge-success")
    expect(assign_badge.text).to eq "Assigned"
  end

  it "when a volunteer unassign from a case" do
    unassign_button = page.find("input.btn-outline-danger")
    expect(unassign_button.value).to eq "Unassign Volunteer"

    click_on "Unassign Volunteer"

    assign_badge = page.find("span.badge-danger")
    expect(assign_badge.text).to eq "Unassigned"
  end

  it "when a volunteer unassign from a case by other a supervisor" do
    click_on "Log out"
    supervisor2 = create(:user, :supervisor)
    sign_in supervisor2
    visit casa_case_path(casa_case.id)
    click_on "Edit Case Details"

    unassign_button = page.find("input.btn-outline-danger")
    expect(unassign_button.value).to eq "Unassign Volunteer"

    click_on "Unassign Volunteer"

    assign_badge = page.find("span.badge-danger")
    expect(assign_badge.text).to eq "Unassigned"
  end
end
