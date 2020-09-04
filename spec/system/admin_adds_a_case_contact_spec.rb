require "rails_helper"

RSpec.describe "admin or supervisor adds a case contact", type: :system do

  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }

  before do
    sign_in admin

    visit casa_case_path(casa_case.id)
    click_on "New Case Contact"

    check "School"
    check "Therapist"
    choose "Yes"
    select "Video", from: "case_contact[medium_type]"
    fill_in "case_contact_occurred_at", with: "04/04/2020"
  end

  it "is successful" do
    fill_in "case-contact-duration-hours", with: "1"
    fill_in "case-contact-duration-minutes", with: "45"

    expect {
      click_on "Submit"
    }.to change(CaseContact, :count).by(1)

    expect(CaseContact.first.casa_case_id).to eq casa_case.id
    expect(CaseContact.first.contact_types).to include "school"
    expect(CaseContact.first.contact_types).to include "therapist"
    expect(CaseContact.first.duration_minutes).to eq 105
  end

  context "with invalid inputs" do
    it "does not submit the form" do
      fill_in "case-contact-duration-hours", with: "0"
      fill_in "case-contact-duration-minutes", with: "5"

      expect {
        click_on "Submit"
      }.not_to change(CaseContact, :count)
    end
  end
end
