require "rails_helper"

RSpec.describe "volunteer adds a case contact", type: :system do
  it "is successful" do
    volunteer = create(:volunteer, :with_casa_cases)
    volunteer_casa_case_one = volunteer.casa_cases.first

    sign_in volunteer

    visit new_case_contact_path

    check volunteer_casa_case_one.case_number
    check "School"
    check "Therapist"
    choose "Yes"
    select "In Person", from: "Contact medium"
    fill_in "case-contact-duration-hours", with: "1"
    fill_in "case-contact-duration-minutes", with: "45"
    fill_in "Occurred at", with: "04/04/2020"
    fill_in "Miles driven", with: "30"
    select "Yes", from: "Want driving reimbursement"
    fill_in "Notes", with: "Hello world"

    expect(page).not_to have_text("error")
    expect {
      click_on "Submit"
    }.to change(CaseContact, :count).by(1)
    expect(CaseContact.first.casa_case_id).to eq volunteer_casa_case_one.id
    expect(CaseContact.first.contact_types).to include "school"
    expect(CaseContact.first.contact_types).to include "therapist"
    expect(CaseContact.first.duration_minutes).to eq 105
  end

  context "with invalid inputs" do
    it "re-renders the form with errors, but preserving all previously entered selections" do
      volunteer = create(:volunteer, :with_casa_cases)
      volunteer_casa_case_one = volunteer.casa_cases.first
      future_date = 2.days.from_now

      sign_in volunteer

      visit new_case_contact_path

      check volunteer_casa_case_one.case_number
      check "School"
      check "Therapist"
      choose "Yes"
      select "In Person", from: "Contact medium"
      fill_in "case-contact-duration-hours", with: "1"
      fill_in "case-contact-duration-minutes", with: "45"
      # Future date: invalid
      fill_in "Occurred at", with: future_date.strftime("%m/%d/%Y")
      fill_in "Miles driven", with: "30"
      select "Yes", from: "Want driving reimbursement"
      fill_in "Notes", with: "Hello world"

      expect {
        click_on "Submit"
      }.not_to change(CaseContact, :count)

      expect(page).to have_text("Occurred at cannot be in the future")
      expect(page).to have_checked_field(volunteer_casa_case_one.case_number)
      expect(page).to have_unchecked_field("Attorney")
      expect(page).to have_checked_field("School")
      expect(page).to have_checked_field("Therapist")
      expect(page).to have_checked_field("Yes")
      expect(page).to have_select("Contact medium", selected: "In Person")
      expect(page).to have_field("case-contact-duration-hours", with: "1")
      expect(page).to have_field("case-contact-duration-minutes", with: "45")
      expect(page).to have_field("Occurred at", with: future_date.strftime("%Y-%m-%d"))
      expect(page).to have_field("Miles driven", with: "30")
      expect(page).to have_select("Want driving reimbursement", selected: "Yes")
      expect(page).to have_field("Notes", with: "Hello world")
    end
  end

  context "with contact made not checked" do
    it "does not re-render form, preserves all previously entered selections" do
      volunteer = create(:volunteer, :with_casa_cases)
      volunteer_casa_case_one = volunteer.casa_cases.first
      future_date = 2.days.from_now

      sign_in volunteer

      visit new_case_contact_path

      check volunteer_casa_case_one.case_number
      check "School"
      check "Therapist"
      select "In Person", from: "Contact medium"
      fill_in "case-contact-duration-hours", with: "1"
      fill_in "case-contact-duration-minutes", with: "45"
      # Future date: invalid
      fill_in "Occurred at", with: future_date.strftime("%m/%d/%Y")
      fill_in "Miles driven", with: "30"
      select "Yes", from: "Want driving reimbursement"
      fill_in "Notes", with: "Hello world"

      expect {
        click_on "Submit"
      }.not_to change(CaseContact, :count)

      expect(page).not_to have_text("Occurred at cannot be in the future")
      expect(page).to have_checked_field(volunteer_casa_case_one.case_number)
      expect(page).to have_unchecked_field("Attorney")
      expect(page).to have_checked_field("School")
      expect(page).to have_checked_field("Therapist")
      expect(page).not_to have_checked_field("Yes")
      expect(page).not_to have_checked_field("No")
      expect(page).to have_select("Contact medium", selected: "In Person")
      expect(page).to have_field("case-contact-duration-hours", with: "1")
      expect(page).to have_field("case-contact-duration-minutes", with: "45")
      expect(page).to have_field("Occurred at", with: future_date.strftime("%Y-%m-%d"))
      expect(page).to have_field("Miles driven", with: "30")
      expect(page).to have_select("Want driving reimbursement", selected: "Yes")
      expect(page).to have_field("Notes", with: "Hello world")
    end
  end
end
