require "rails_helper"

RSpec.describe "admin or supervisor adds a case contact", type: :feature do
  it "is successful" do
    admin = create(:user, :casa_admin)
    casa_case = create(:casa_case)

    sign_in admin

    visit casa_case_path(casa_case.id)
    click_on "New Case Contact"

    find(:css, "input.casa-case-id-check[value='#{casa_case.id}']").set(true)
    find(:css, "input.casa-case-contact-type[value='school']").set(true)
    find(:css, "input.casa-case-contact-type[value='therapist']").set(true)
    select "1 hour", from: "case_contact[duration_hours]"
    select "45 minutes", from: "case_contact[duration_minutes]"
    fill_in "case_contact_occurred_at", with: "04/04/2020"

    expect {
      click_on "Submit"
    }.to change(CaseContact, :count).by(1)

    expect(CaseContact.first.casa_case_id).to eq casa_case.id
    expect(CaseContact.first.contact_types).to include "school"
    expect(CaseContact.first.contact_types).to include "therapist"
    expect(CaseContact.first.duration_minutes).to eq 105
  end
end
