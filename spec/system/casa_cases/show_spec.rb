require "rails_helper"

RSpec.describe "casa_cases/show", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:volunteer) { build(:volunteer, display_name: "Bob Loblaw", casa_org: organization) }
  let(:casa_case) {
    create(:casa_case, :with_one_court_mandate, casa_org: organization,
    case_number: "CINA-1", transition_aged_youth: true)
  }
  let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }
  let!(:case_contact) { create(:case_contact, creator: volunteer, casa_case: casa_case) }
  let!(:emancipation_categories) { create_list(:emancipation_category, 3) }

  before do
    sign_in user
    visit casa_case_path(casa_case.id)
  end

  context "when admin" do
    let(:user) { admin }

    it_behaves_like "shows past court dates links"

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
      expect(page).to have_content("Court Orders")
      expect(page).to have_content(casa_case.case_court_mandates[0].mandate_text)
      expect(page).to have_content(casa_case.case_court_mandates[0].implementation_status_symbol)
    end
  end

  context "supervisor user" do
    let(:user) { create(:supervisor, casa_org: organization) }
    let!(:case_contact) { create(:case_contact, creator: user, casa_case: casa_case) }

    it "sees link to own edit page" do
      expect(page).to have_link(href: "/supervisors/#{user.id}/edit")
    end

    context "case contact by another supervisor" do
      let(:other_supervisor) { create(:supervisor, casa_org: organization) }
      let!(:case_contact) { create(:case_contact, creator: other_supervisor, casa_case: casa_case) }
      it "sees link to other supervisor" do
        expect(page).to have_link(href: "/supervisors/#{other_supervisor.id}/edit")
      end
    end

    it "can see court mandates" do
      expect(page).to have_content("Court Orders")
      expect(page).to have_content(casa_case.case_court_mandates[0].mandate_text)
      expect(page).to have_content(casa_case.case_court_mandates[0].implementation_status_symbol)
    end

    context "when generating a report, supervisor sees waiting page", js: true do
      before do
        click_button "Generate Report"
      end

      describe "'Generate Report' button" do
        it "has been disabled" do
          options = {visible: :visible}

          expect(page).to have_selector "#btnGenerateReport[disabled]", **options
        end
      end

      describe "Spinner" do
        it "becomes visible" do
          options = {visible: :visible}

          expect(page).to have_selector "#spinner", **options
        end
      end
    end
  end

  context "volunteer user" do
    let(:user) { volunteer }

    it "sees link to emancipation" do
      expect(page).to have_link("Emancipation 0 / #{emancipation_categories.size}")
    end

    it "can see court mandates" do
      expect(page).to have_content("Court Orders")
      expect(page).to have_content(casa_case.case_court_mandates[0].mandate_text)
      expect(page).to have_content(casa_case.case_court_mandates[0].implementation_status_symbol)
    end
  end
end
