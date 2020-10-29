require "rails_helper"

RSpec.describe "volunteer edits a case contact", type: :system do
  let(:volunteer) { create(:volunteer) }
  let(:casa_case) { create(:casa_case, casa_org: volunteer.casa_org) }
  let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }

  it "is successful" do
    case_contact = create(:case_contact, duration_minutes: 105, casa_case: casa_case, creator: volunteer)
    sign_in volunteer
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

  context "when the case contact occurred last quarter" do
    let!(:case_contact) { create(:case_contact, creator: volunteer, casa_case: casa_case, occurred_at: 94.days.ago) }

    before do
      sign_in volunteer
      visit case_contacts_path
    end

    it "contact does not have 'Edit' link" do
      expect(page).not_to have_link "Edit", href: edit_case_contact_path(case_contact)
    end

    it "contact has tooltip" do
      expect(page).to have_css("i.fa-question-circle")
    end
  end
end
