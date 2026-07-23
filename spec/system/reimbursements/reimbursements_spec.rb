# frozen_string_literal: true

require "rails_helper"

RSpec.describe "reimbursements", type: :system do
  let(:admin) { create(:casa_admin) }
  let!(:contact1) { create(:case_contact, :wants_reimbursement) }
  let!(:contact2) { create(:case_contact, :wants_reimbursement) }

  before do
    sign_in admin
    visit reimbursements_path
  end

  it "shows the reimbursement queue" do
    expect(page).to have_content("Needs review")
    expect(page).to have_content("Reimbursement complete")
    expect(page).to have_content("Occurred at")
    expect(page).to have_content(contact1.casa_case.case_number)
    expect(page).to have_content(contact2.miles_driven)
  end

  it "shows a result count and a row per reimbursement" do
    expect(page).to have_content("Showing")
    expect(page).to have_selector("[data-test=reimbursement-row]", count: 2)
  end

  it "filters by volunteer", :js do
    expect(page).to have_selector("[data-test=reimbursement-row]", count: 2)

    select contact1.creator.display_name, from: "Volunteer"

    expect(page).to have_selector("[data-test=reimbursement-row]", count: 1)
    # contact2's volunteer is still listed as a filter option, so scope to the row.
    within "[data-test=reimbursement-row]" do
      expect(page).to have_content(contact1.creator.display_name)
      expect(page).to have_no_content(contact2.creator.display_name)
    end
  end
end
