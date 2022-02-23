require "rails_helper"

RSpec.describe "reimbursements", type: :system do
  let(:admin) { create(:casa_admin) }

  it "shows reimbursements" do
    sign_in admin

    contact1 = create(:case_contact, :wants_reimbursement)
    contact2 = create(:case_contact, :wants_reimbursement)

    visit reimbursements_path
    expect(page).to have_content("Needs Review")
    expect(page).to have_content("Reimbursement Complete")
    expect(page).to have_content("Occurred At")
    expect(page).to have_content(contact1.casa_case.case_number)
    expect(page).to have_content(contact2.miles_driven)
  end
end
