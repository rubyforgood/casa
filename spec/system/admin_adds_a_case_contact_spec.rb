require "rails_helper"

RSpec.describe "admin or supervisor adds a case contact", type: :system do

  let(:admin) { create(:casa_admin) }
  let(:casa_case) { create(:casa_case) }

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
    context "with js" do
      it "does not submit the form" do
        fill_in "case-contact-duration-hours", with: "0"
        fill_in "case-contact-duration-minutes", with: "5"

        expect {
          click_on "Submit"
        }.not_to change(CaseContact, :count)
      end
    end
  end

  context "without js", js: false do
    it "re-renders the form with error messages and with only current Casa Case" do

      fill_in "case-contact-duration-hours", with: "0"
      fill_in "case-contact-duration-minutes", with: "5"

      expect {
        click_on "Submit"
      }.not_to change(CaseContact, :count)

      expect(page).to have_text("Minimum case contact duration should be 15 minutes.")
      expect(page.all("input.casa-case-id-check").count).to eq 1
    end
  end
end
