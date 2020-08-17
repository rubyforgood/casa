require "rails_helper"

RSpec.describe "admin or supervisor assign and unassign a volunteer to case", type: :feature do
  let(:supervisor1) { create(:supervisor) }
  let(:casa_case) { create(:casa_case) }

  before do
    sign_in supervisor1
    volunteer = create(:volunteer)
    visit casa_case_path(casa_case.id)
    click_on "Edit Case Details"

    select volunteer.email, from: "case_assignment[volunteer_id]"

    click_on "Assign Volunteer"
  end

  context "when a volunteer is assigned to a case" do
    it 'marks the volunteer as assigned and shows the start date of the assignment' do
      expect(casa_case.case_assignments.count).to eq 1

      unassign_button = page.find("input.btn-outline-danger")
      expect(unassign_button.value).to eq "Unassign Volunteer"

      assign_badge = page.find("span.badge-success")
      expect(assign_badge.text).to eq "Assigned"

      end

    it "shows an assignment start date and no assignment end date" do
      expected_start_date = Date.today.strftime("%B %e, %Y")
      assignment_start = page.find("#assignment-start").text
      assignment_end = page.find("#assignment-end").text

      expect(assignment_start).to eq(expected_start_date)
      expect(assignment_end).to be_empty
    end
  end

  context "when a volunteer is unassigned from a case" do
    it "marks the volunteer as unassigned" do
      unassign_button = page.find("input.btn-outline-danger")
      expect(unassign_button.value).to eq "Unassign Volunteer"

      click_on "Unassign Volunteer"

      assign_badge = page.find("span.badge-danger")
      expect(assign_badge.text).to eq "Unassigned"
    end

    it "shows an assignment start date and an assignment end date" do
      expected_start_and_end_date = Date.today.strftime("%B %e, %Y")

      click_on "Unassign Volunteer"

      assignment_start = page.find("#assignment-start").text
      assignment_end = page.find("#assignment-end").text

      expect(assignment_start).to eq(expected_start_and_end_date)
      expect(assignment_end).to eq(expected_start_and_end_date)
    end
  end

  it "when a volunteer unassign from a case by other a supervisor" do
    click_on "Log out"
    supervisor2 = create(:supervisor)
    sign_in supervisor2
    visit casa_case_path(casa_case.id)
    click_on "Edit Case Details"

    unassign_button = page.find("input.btn-outline-danger")
    expect(unassign_button.value).to eq "Unassign Volunteer"

    click_on "Unassign Volunteer"

    assign_badge = page.find("span.badge-danger")
    expect(assign_badge.text).to eq "Unassigned"
  end

  it "when can assign only active volunteer to a case" do
    volunteer1 = create(:volunteer)
    volunteer2 = create(:volunteer, :inactive)

    expect(find("select[name='case_assignment[volunteer_id]']").all('option').count).to eq 1
  end
end
