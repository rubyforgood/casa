require "rails_helper"

RSpec.describe "admin or supervisor edits a case contact", type: :system do
  it "is successful" do
    admin = create(:casa_admin)
    casa_case = create(:casa_case)

    sign_in admin

    visit casa_case_path(casa_case.id)
    click_on "New Case Contact"

    check "School"
    choose "Yes"

    select "Video", from: "case_contact[medium_type]"
    fill_in "case-contact-duration-hours", with: "1"
    fill_in "case-contact-duration-minutes", with: "45"
    fill_in "case_contact_occurred_at", with: "04/04/2020"

    click_on "Submit"

    visit edit_case_contact_path(CaseContact.first)

    select "Letter", from: "case_contact[medium_type]"
    expect(find(:css, "input#case_contact_contact_made_true").value).to eq "true"

    click_on "Submit"

    expect(CaseContact.first.casa_case_id).to eq casa_case.id
    expect(CaseContact.first.duration_minutes).to eq 105
    expect(CaseContact.first.medium_type).to eq "letter"
    expect(CaseContact.first.contact_made).to eq true
  end
end
