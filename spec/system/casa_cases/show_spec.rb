require "rails_helper"

RSpec.describe "casa_cases/show", :disable_bullet, type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:volunteer) { create(:volunteer, display_name: "Bob Loblaw", casa_org: organization) }
  let(:casa_case) { create(:casa_case, :with_one_court_mandate, casa_org: organization, case_number: "CINA-1") }
  let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }
  let!(:case_contact) { create(:case_contact, creator: volunteer, casa_case: casa_case) }

  before do
    sign_in user
    visit casa_case_path(casa_case.id)
  end

  context "when admin" do
    let(:user) { admin }

    it "can see case creator in table" do
      expect(page).to have_text("Bob Loblaw")
    end

    it "can navigate to edit volunteer page" do
      expect(page).to have_link("Bob Loblaw", href: "/volunteers/#{volunteer.id}/edit")
    end

    it "sees link to profile page" do
      expect(page).to have_link(href: "/users/edit")
    end

    it "can see court mandates" do
      expect(page).to have_content("Court Mandates")
      expect(page).to have_content(casa_case.case_court_mandates[0].mandate_text)
    end
  end

  context "supervisor user" do
    let(:user) { create(:supervisor, casa_org: organization) }
    let!(:case_contact) { create(:case_contact, creator: user, casa_case: casa_case) }

    it "sees link to own edit page" do
      expect(page).to have_link(href: "/supervisors/#{user.id}/edit")
    end

    it "can see court mandates" do
      expect(page).to have_content("Court Mandates")
      expect(page).to have_content(casa_case.case_court_mandates[0].mandate_text)
    end
  end

  context "volunteer user" do
    let(:user) { volunteer }

    it "sees link to emancipation" do
      expect(page).to have_content(casa_case.case_number)
    end

    it "can see court mandates" do
      expect(page).to have_content("Court Mandates")
      expect(page).to have_content(casa_case.case_court_mandates[0].mandate_text)
    end
  end
end
