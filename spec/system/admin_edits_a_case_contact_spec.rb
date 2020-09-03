require "rails_helper"

RSpec.describe "admin or supervisor edits a case contact", type: :system do
  let(:organization) { create(:casa_org) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }
  let!(:case_contact) { create(:case_contact, duration_minutes: 105, casa_case: casa_case) }

  it "is successful" do
    admin = create(:casa_admin, casa_org: organization)
    sign_in admin

    visit edit_case_contact_path(case_contact)

    choose "Yes"
    select "Letter", from: "case_contact[medium_type]"

    click_on "Submit"

    case_contact.reload
    expect(case_contact.casa_case_id).to eq casa_case.id
    expect(case_contact.duration_minutes).to eq 105
    expect(case_contact.medium_type).to eq "letter"
    expect(case_contact.contact_made).to eq true
  end

  it "fails across organizations"
end
