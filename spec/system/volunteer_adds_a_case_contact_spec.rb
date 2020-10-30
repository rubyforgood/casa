require "rails_helper"

RSpec.describe "volunteer adds a case contact", type: :system do
  let(:organization) { create(:casa_org) }
  let!(:empty) { create(:contact_type_group, name: "Empty", casa_org: organization) }
  let!(:grp_with_hidden) { create(:contact_type_group, name: "OnlyHiddenTypes", casa_org: organization) }
  let!(:hidden_type) { create(:contact_type, name: "Hidden", active: false, contact_type_group: grp_with_hidden) }

  it "is successful" do
    volunteer = create(:volunteer, :with_casa_cases)
    volunteer_casa_case_one = volunteer.casa_cases.first
    create_contact_types(volunteer_casa_case_one.casa_org)

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
    expect(page).to_not have_text("Empty") # this line and the next should work like the admin_adds_a_case_contact_spec but does not
    expect(page).to_not have_text("Hidden") # will review after these test cases have been re-factored

    click_on "Submit"
    expect(page).to have_text("Confirm Note Content")
    expect {
      click_on "Continue Submitting"
    }.to change(CaseContact, :count).by(1)

    expect(CaseContact.first.casa_case_id).to eq volunteer_casa_case_one.id
    expect(CaseContact.first.contact_types.map(&:name)).to include "School"
    expect(CaseContact.first.contact_types.map(&:name)).to include "Therapist"
    expect(CaseContact.first.duration_minutes).to eq 105
  end

  it "submits the form when no note was added" do
    volunteer = create(:volunteer, :with_casa_cases)
    volunteer_casa_case_one = volunteer.casa_cases.first
    create_contact_types(volunteer_casa_case_one.casa_org)

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
    fill_in "Notes", with: ""

    expect(page).not_to have_text("error")
    expect {
      click_on "Submit"
    }.to change(CaseContact, :count).by(1)

    expect(CaseContact.first.notes).to eq ""
  end

  it "submits the form when note is added and confirmed" do
    volunteer = create(:volunteer, :with_casa_cases)
    volunteer_casa_case_one = volunteer.casa_cases.first
    create_contact_types(volunteer_casa_case_one.casa_org)

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
    fill_in "Notes", with: "This is the note"

    expect(page).not_to have_text("error")
    click_on "Submit"
    expect(page).to have_text("Confirm Note Content")
    expect {
      click_on "Continue Submitting"
    }.to change(CaseContact, :count).by(1)

    expect(CaseContact.first.notes).to eq "This is the note"
  end

  it "does not submit the form when note is added but not confirmed" do
    volunteer = create(:volunteer, :with_casa_cases)
    volunteer_casa_case_one = volunteer.casa_cases.first
    create_contact_types(volunteer_casa_case_one.casa_org)

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
    fill_in "Notes", with: "This is the note"

    expect(page).not_to have_text("error")
    click_on "Submit"
    expect(page).to have_text("Confirm Note Content")
    expect {
      click_on "Go Back to Form"
    }.not_to change(CaseContact, :count)
  end

  context "with invalid inputs" do
    xit "re-renders the form with errors, but preserving all previously entered selections" do
      volunteer = create(:volunteer, :with_casa_cases)
      volunteer_casa_case_one = volunteer.casa_cases.first
      future_date = 2.days.from_now
      create_contact_types(volunteer_casa_case_one.casa_org)

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
      fill_in "Occurred at", with: future_date.strftime("%Y/%m/%d")
      fill_in "Miles driven", with: "30"
      select "Yes", from: "Want driving reimbursement"
      fill_in "Notes", with: "Hello world"

      click_on "Submit"
      expect(page).to have_text("Confirm Note Content")
      expect {
        click_on "Continue Submitting"
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
      create_contact_types(volunteer_casa_case_one.casa_org)

      sign_in volunteer

      visit new_case_contact_path

      check volunteer_casa_case_one.case_number
      check "School"
      check "Therapist"
      select "In Person", from: "Contact medium"
      fill_in "case-contact-duration-hours", with: "1"
      fill_in "case-contact-duration-minutes", with: "45"
      # Future date: invalid
      fill_in "Occurred at", with: future_date.strftime("%Y-%m-%d")
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
      expect(page).to have_field("Occurred at", with: future_date.strftime("%Y/%m/%d"))
      expect(page).to have_field("Miles driven", with: "30")
      expect(page).to have_select("Want driving reimbursement", selected: "Yes")
      expect(page).to have_field("Notes", with: "Hello world")
    end
  end

  private

  def create_contact_types(org)
    create(:contact_type_group, casa_org: org).tap do |group|
      create(:contact_type, contact_type_group: group, name: "Attorney")
      create(:contact_type, contact_type_group: group, name: "School")
      create(:contact_type, contact_type_group: group, name: "Therapist")
    end
  end
end
