require "rails_helper"

RSpec.describe "admin or supervisor assign and unassign a volunteer to case", type: :system do
  let(:organization) { create(:casa_org) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }
  let(:supervisor1) { create(:supervisor, casa_org: organization) }
  let!(:volunteer) { create(:volunteer, supervisor: supervisor1, casa_org: organization) }

  before do
    travel_to Time.zone.local(2020, 8, 29, 4, 5, 6)
    sign_in supervisor1
    visit casa_case_path(casa_case.id)
    click_on "Edit Case Details"

    select volunteer.display_name, from: "case_assignment[volunteer_id]"

    click_on "Assign Volunteer"
  end

  after { travel_back }

  context "when a volunteer is assigned to a case" do
    it "marks the volunteer as assigned and shows the start date of the assignment" do
      expect(casa_case.case_assignments.count).to eq 1

      unassign_button = page.find("input.btn-outline-danger")
      expect(unassign_button.value).to eq "Unassign Volunteer"

      assign_badge = page.find("span.badge-success")
      expect(assign_badge.text).to eq "ASSIGNED"
    end

    it "shows an assignment start date and no assignment end date" do
      assignment_start = page.find("td[data-test=assignment-start]").text
      assignment_end = page.find("td[data-test=assignment-end]").text

      expect(assignment_start).to eq("August 29, 2020")
      expect(assignment_end).to be_empty
    end
  end

  context "when a volunteer is unassigned from a case" do
    it "marks the volunteer as unassigned and shows assignment start/end dates" do
      unassign_button = page.find("input.btn-outline-danger")
      expect(unassign_button.value).to eq "Unassign Volunteer"

      click_on "Unassign Volunteer"

      assign_badge = page.find("span.badge-danger")
      expect(assign_badge.text).to eq "UNASSIGNED"

      expected_start_and_end_date = "August 29, 2020"

      assignment_start = page.find("td[data-test=assignment-start]").text
      assignment_end = page.find("td[data-test=assignment-end]").text

      expect(assignment_start).to eq(expected_start_and_end_date)
      expect(assignment_end).to eq(expected_start_and_end_date)
    end
  end

  context "when supervisor other than volunteer's supervisor" do
    before { volunteer.update(supervisor: create(:supervisor)) }

    it "unassigns volunteer" do
      unassign_button = page.find("input.btn-outline-danger")
      expect(unassign_button.value).to eq "Unassign Volunteer"

      click_on "Unassign Volunteer"

      assign_badge = page.find("span.badge-danger")
      expect(assign_badge.text).to eq "UNASSIGNED"
    end
  end

  it "when can assign only active volunteer to a case" do
    create(:volunteer, casa_org: organization)
    create(:volunteer, :inactive, casa_org: organization)

    expect(find("select[name='case_assignment[volunteer_id]']").all("option").count).to eq 1
  end
end
