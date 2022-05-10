require "rails_helper"

RSpec.describe "casa_cases/show", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:volunteer) { build(:volunteer, display_name: "Bob Loblaw", casa_org: organization) }
  let(:casa_case) {
    create(:casa_case, :with_casa_case_contact_types, :with_one_court_order, casa_org: organization,
    case_number: "CINA-1", court_report_due_date: 1.month.from_now)
  }
  let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }
  let!(:case_contact) { create(:case_contact, creator: volunteer, casa_case: casa_case) }
  let!(:emancipation_categories) { create_list(:emancipation_category, 3) }
  let!(:future_court_date) { create(:court_date, date: 1.year.from_now, casa_case: casa_case) }

  before do
    sign_in user
    visit casa_case_path(casa_case.id)
  end

  shared_examples "shows emancipation checklist link" do
    context "when youth is in transition age" do
      it "sees link to emancipation" do
        expect(page).to have_link("Emancipation 0 / #{emancipation_categories.size}")
      end
    end

    context "when youth is not in transition age" do
      before do
        casa_case.update!(birth_month_year_youth: DateTime.current)
        visit casa_case_path(casa_case)
      end

      it "does not see a link to emancipation checklist" do
        expect(page).not_to have_link("Emancipation 0 / #{emancipation_categories.size}")
      end
    end
  end

  context "admin user" do
    let(:user) { admin }

    it_behaves_like "shows court dates links"
    it_behaves_like "shows emancipation checklist link"

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

    xit "can see next court date", js: true do # TODO fix and re-enable
      expect(page).to have_content(
        "Next Court Date: #{I18n.l(future_court_date.date, format: :day_and_date, default: "")}"
      )
    end

    it "can see Add to Calendar buttons", js: true do
      expect(page).to have_content("Add to Calendar")
    end

    context "when there is no future court date or court report due date" do
      before do
        casa_case = create(:casa_case, casa_org: organization)
        visit casa_case_path(casa_case.id)
      end

      it "can not see Add to Calendar buttons", js: true do
        expect(page).not_to have_content("Add to Calendar")
      end
    end
  end

  context "supervisor user" do
    let(:user) { create(:supervisor, casa_org: organization) }
    let!(:case_contact) { create(:case_contact, creator: user, casa_case: casa_case) }

    it_behaves_like "shows emancipation checklist link"

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

    it_behaves_like "shows emancipation checklist link"

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

    it "when partial implemented" do
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
