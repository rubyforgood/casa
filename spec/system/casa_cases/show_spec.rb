require "rails_helper"

RSpec.describe "casa_cases/show", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:volunteer) { build(:volunteer, display_name: "Bob Loblaw", casa_org: organization) }
  let(:casa_case) {
    create(:casa_case, :with_one_court_order, casa_org: organization,
    case_number: "CINA-1", transition_aged_youth: true, court_report_due_date: 1.month.from_now)
  }
  let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }
  let!(:case_contact) { create(:case_contact, creator: volunteer, casa_case: casa_case) }
  let!(:emancipation_categories) { create_list(:emancipation_category, 3) }
  let!(:future_court_date) { create(:court_date, date: 1.year.from_now, casa_case: casa_case) }

  before do
    sign_in user
    visit casa_case_path(casa_case.id)
  end

  context "when admin" do
    let(:user) { admin }

    it_behaves_like "shows court dates links"

    it "can see case creator in table" do
      expect(page).to have_text("Bob Loblaw")
    end

    it "can navigate to edit volunteer page" do
      expect(page).to have_link("Bob Loblaw", href: "/volunteers/#{volunteer.id}/edit")
    end

    it "sees link to profile page" do
      expect(page).to have_link(href: "/users/edit")
    end

    it "can see court orders" do
      expect(page).to have_content("Court Orders")
      expect(page).to have_content(casa_case.case_court_orders[0].text)
      expect(page).to have_content(casa_case.case_court_orders[0].implementation_status_symbol)
    end

    it "can see next court date", js: true do
      if casa_case.court_date
        expect(page).to have_content("Next Court Date: #{I18n.l(future_court_date.date, format: :day_and_date, default: "")}")
      end
    end

    xit "can see Add to Calendar buttons", js: true do # this is broken by us exceeding our license for the calendar button
      expect(page).to have_content("Add Court Report Due Date for #{casa_case.case_number} to Calendar")
      expect(page).to have_content("Add Next Court Date for #{casa_case.case_number} to Calendar")
    end

    context "when there is no future court date or court report due date" do
      before do
        casa_case = create(:casa_case, casa_org: organization)
        visit casa_case_path(casa_case.id)
      end

      it "can not see Add to Calendar buttons", js: true do
        expect(page).not_to have_content("Add Court Report Due Date for #{casa_case.case_number} to Calendar")
        expect(page).not_to have_content("Add Next Court Date #{casa_case.case_number} to Calendar")
      end
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

    it "can see court orders" do
      expect(page).to have_content("Court Orders")
      expect(page).to have_content(casa_case.case_court_orders[0].text)
      expect(page).to have_content(casa_case.case_court_orders[0].implementation_status_symbol)
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

    it "can see court orders" do
      expect(page).to have_content("Court Orders")
      expect(page).to have_content(casa_case.case_court_orders[0].text)
      expect(page).to have_content(casa_case.case_court_orders[0].implementation_status_symbol)
    end
  end

  context "court order - implementation status symbol" do
    let(:user) { admin }

    it "when implemented" do
      casa_case.case_court_orders[0].update(implementation_status: :implemented)

      visit casa_case_path(casa_case)

      expect(page).to have_content("Court Orders")
      expect(page).to have_content(casa_case.case_court_orders[0].text)
      expect(page).to have_content("✅")
    end

    it "when not implemented" do
      casa_case.case_court_orders[0].update(implementation_status: :not_implemented)

      visit casa_case_path(casa_case)

      expect(page).to have_content("Court Orders")
      expect(page).to have_content(casa_case.case_court_orders[0].text)
      expect(page).to have_content("❌")
    end

    it "when partiall implemented" do
      casa_case.case_court_orders[0].update(implementation_status: :partially_implemented)

      visit casa_case_path(casa_case)

      expect(page).to have_content("Court Orders")
      expect(page).to have_content(casa_case.case_court_orders[0].text)
      expect(page).to have_content("🕗")
    end

    it "when not specified" do
      casa_case.case_court_orders[0].update(implementation_status: nil)

      visit casa_case_path(casa_case)

      expect(page).to have_content("Court Orders")
      expect(page).to have_content(casa_case.case_court_orders[0].text)
      expect(page).to have_content("❌")
    end
  end
end
