# frozen_string_literal: true

require "rails_helper"

RSpec.describe "reimbursements" do
  let(:casa_org) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org:) }
  let(:contact) { create(:case_contact, :wants_reimbursement, casa_org:) }
  let(:contact_two) { create(:case_contact, :wants_reimbursement, casa_org:) }

  before do
    contact
    contact_two
    sign_in admin
    visit reimbursements_path
  end

  it "shows reimbursements", :js do
    expect(page).to have_content("Needs Review")
    expect(page).to have_content("Reimbursement Complete")
    expect(page).to have_content("Occurred At")
    expect(page).to have_content(contact.casa_case.case_number)
    expect(page).to have_content(contact_two.miles_driven)
  end

  it "shows pagination", :js do
    expect(page).to have_content("Previous")
    expect(page).to have_content("Next")
  end

  it "filters by volunteers", :js do
    expect(page).to have_css("#reimbursements-datatable tbody tr", count: 2)

    page.find(".select2-search__field").click
    send_keys(contact.creator.display_name)
    send_keys(:enter)

    expect(page).to have_css("#reimbursements-datatable tbody tr", count: 1)
    expect(page).to have_content contact.creator.display_name

    page.find(".select2-selection__choice__remove").click

    expect(page).to have_css("#reimbursements-datatable tbody tr", count: 2)
  end
end
