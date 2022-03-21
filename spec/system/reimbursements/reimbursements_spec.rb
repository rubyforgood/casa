require "rails_helper"

RSpec.describe "reimbursements", type: :system do
  let(:admin) { create(:casa_admin) }

  it "shows reimbursements" do
    sign_in admin

    contact1 = create(:case_contact, :wants_reimbursement)
    contact2 = create(:case_contact, :wants_reimbursement)

    visit reimbursements_path
    expect(page).to have_content("Reimbursement Queue")
    expect(page).to have_content("Needs Review")
    expect(page).to have_content("Reimbursement Complete")
    expect(page).to have_content("Volunteer")
    expect(page).to have_content("Case Number")
    expect(page).to have_content("Contact Types")
    expect(page).to have_content("Occurred At")
    expect(page).to have_content("Expense Type")
    expect(page).to have_content("Description")
    expect(page).to have_content("Miles Driven")
    expect(page).to have_content("Reimbursement Complete")
    expect(page).to have_content(contact1.casa_case.case_number)
    expect(page).to have_content(contact2.miles_driven)
  end
end
