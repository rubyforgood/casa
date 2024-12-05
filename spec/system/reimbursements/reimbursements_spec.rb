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

  it "shows reimbursements", :js do
    expect(page).to have_content("Needs Review")
    expect(page).to have_content("Reimbursement Complete")
    expect(page).to have_content("Occurred At")
    expect(page).to have_content(contact1.casa_case.case_number)
    expect(page).to have_content(contact2.miles_driven)
  end

  it "shows pagination", :js do
    expect(page).to have_content("Previous")
    expect(page).to have_content("Next")
  end

  it "filters by volunteers", :js do
    expect(page).to have_selector("#reimbursements-datatable tbody tr", count: 2)

    page.find(".select2-search__field").click
    send_keys(contact1.creator.display_name)
    send_keys(:enter)

    expect(page).to have_selector("#reimbursements-datatable tbody tr", count: 1)
    expect(page).to have_content contact1.creator.display_name

    page.find(".select2-selection__choice__remove").click

    expect(page).to have_selector("#reimbursements-datatable tbody tr", count: 2)
  end
end
