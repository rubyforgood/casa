require "rails_helper"

RSpec.describe "case_contacts reimbursement volunteer picker", :flipper, type: :system do
  let(:org) { create :casa_org, :all_reimbursements_enabled }
  let(:admin) { create :casa_admin, casa_org: org }
  let(:casa_case) { create :casa_case, casa_org: org }
  let(:ct) { create :contact_type, casa_org: org }
  let!(:vol1) { create :volunteer, casa_org: org }
  let!(:vol2) { create :volunteer, casa_org: org }
  let!(:a1) { create :case_assignment, casa_case:, volunteer: vol1 }
  let!(:a2) { create :case_assignment, casa_case:, volunteer: vol2 }
  let!(:contact) do
    # reimbursement_volunteer_id (virtual, not persisted) lets it save; on the edit page it's nil
    # again, so the picker is offered -- mirroring an existing ambiguous contact.
    create :case_contact, casa_case:, creator: admin, contact_types: [ct],
      duration_minutes: 60, want_driving_reimbursement: true, miles_driven: 5,
      reimbursement_volunteer_id: vol1.id
  end

  before { sign_in admin }

  it "lets the editor pick a volunteer and saves the address to them", :js do
    visit edit_case_contact_path(contact)

    expect(page).to have_css("#case_contact_reimbursement_volunteer_id")
    expect(page).to have_no_text("No volunteer is assigned")

    find("#case_contact_reimbursement_volunteer_id option[value='#{vol2.id}']").select_option
    fill_in "Address line 1", with: "42 Reimburse Rd"
    fill_in "City", with: "Townsville"
    fill_in "State", with: "CA"
    fill_in "ZIP", with: "90210"
    click_on "Submit"

    expect(page).to have_current_path(case_contacts_path, ignore_query: true)
    expect(vol2.reload.address&.content.to_s).to include("42 Reimburse Rd")
    expect(vol1.reload.address).to be_nil
  end
end
