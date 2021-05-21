require "rails_helper"

RSpec.describe "case_contacts/edit", :disable_bullet, type: :system do
  let(:organization) { create(:casa_org) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }
  let!(:case_contact) { create(:case_contact, duration_minutes: 105, casa_case: casa_case) }

  context "when admin" do
    let(:admin) { create(:casa_admin, casa_org: organization) }

    it "admin successfully edits case contact", js: true do
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

    context "is part of a different organization" do
      let(:other_organization) { create(:casa_org) }
      let(:admin) { create(:casa_admin, casa_org: other_organization) }

      it "fails across organizations" do
        sign_in admin

        visit edit_case_contact_path(case_contact)
        expect(current_path).to eq supervisors_path
      end
    end
  end

  context "volunteer user" do
    let(:volunteer) { create(:volunteer, casa_org: organization) }
    let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }

    it "is successful", js: true do
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
      let!(:case_contact) { create(:case_contact, creator: volunteer, casa_case: casa_case, occurred_at: 5.months.ago) }

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
end
