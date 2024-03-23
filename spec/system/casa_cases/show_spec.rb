require "rails_helper"

RSpec.describe "casa_cases/show", type: :system do
  include ActionView::Helpers::DateHelper

  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:volunteer) { build(:volunteer, display_name: "Bob Loblaw", casa_org: organization) }
  let(:casa_case) {
    create(:casa_case, :with_one_court_order, casa_org: organization,
      case_number: "CINA-1", date_in_care: date_in_care)
  }
  let!(:court_date) { create(:court_date, court_report_due_date: 1.month.from_now) }
  let(:date_in_care) { 6.years.ago }
  let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }
  let!(:case_contact) { create(:case_contact, creator: volunteer, casa_case: casa_case) }
  let!(:emancipation_categories) { create_list(:emancipation_category, 3) }
  let!(:future_court_date) { create(:court_date, date: 21.days.from_now, casa_case: casa_case) }

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

  describe "Report Generation", js: true do
    let(:modal_selector) { '[data-bs-target="#generate-docx-report-modal"]' }
    let(:user) { volunteer }

    before do
      travel_to Date.new(2021, 1, 1)
      sign_in user
      visit casa_case_path(casa_case.id)
    end

    context "when first arriving to 'Generate Court Report' page" do
      it "generation modal hidden" do
        expect(page).to have_selector "#btnGenerateReport", text: "Generate Report", visible: false
        expect(page).not_to have_selector ".select2"
      end
    end

    context "after opening 'Download Court Report' modal" do
      before do
        page.find(modal_selector).click
      end

      # putting all this in the same system test shaves 3 seconds off the test suite
      it "modal has correct contents" do
        start_date = page.find("#start_date").value
        expect(start_date).to eq("January 01, 2021") # default date

        end_date = page.find("#end_date").value
        expect(end_date).to eq("January 01, 2021") # default date

        expect(page).to have_selector "#btnGenerateReport", text: "Generate Report", visible: true
        expect(page).to_not have_selector ".select2"

        expect(page).to have_selector("#btnGenerateReport .lni-download", visible: true)
        expect(page).to_not have_selector("#btnGenerateReport[disabled]")
        expect(page).to have_selector("#spinner", visible: :hidden)

        within("#generate-docx-report-modal") do
          expect(page).to have_content(casa_case.case_number)

          # when choosing the prompt option (value is empty) and click on 'Generate Report' button, nothing should happen"
          # should have disabled generate button, download icon and no spinner
          click_button "Generate Report"
        end

        expect(page).to have_selector("#btnGenerateReport .lni-download", visible: :hidden)
        expect(page).to have_selector("#btnGenerateReport[disabled]")
        expect(page).to have_selector("#spinner", visible: true)
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

    it "can see next court date", js: true do
      expect(page).to have_content(
        "Next Court Date: #{I18n.l(future_court_date.date, format: :day_and_date)}"
      )
    end

    it "can see the youth's Date In Care", js: true do
      expect(page).to have_content(
        "Youth's Date in Care: #{I18n.l(date_in_care, format: :youth_date_of_birth)}"
      )
    end

    it "can see the time since the youth's Date In Care", js: true do
      expect(page).to have_content("#{time_ago_in_words(date_in_care)} ago")
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

    context "when old case contacts are hidden" do
      it "should display all case contacts to admin", js: true do
        casa_case = create(:casa_case, casa_org: organization)
        volunteer_1 = create(:volunteer, display_name: "Volunteer 1", casa_org: casa_case.casa_org)
        volunteer_2 = create(:volunteer, display_name: "Volunteer 2", casa_org: casa_case.casa_org)
        create(:case_assignment, casa_case: casa_case, volunteer: volunteer_1)
        create(:case_assignment, casa_case: casa_case, volunteer: volunteer_2, active: false, hide_old_contacts: true)
        create(:case_contact, contact_made: true, casa_case: casa_case, creator: volunteer_1, occurred_at: DateTime.now - 1)
        create(:case_contact, contact_made: true, casa_case: casa_case, creator: volunteer_2, occurred_at: DateTime.now - 1)

        visit casa_case_path(casa_case.id)

        expect(page).to have_css("#case_contacts_list .card-content", count: 2)
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

    context "when old case contacts are hidden" do
      it "should display all case contacts to supervisor", js: true do
        casa_case = create(:casa_case, casa_org: organization)
        volunteer_1 = create(:volunteer, display_name: "Volunteer 1", casa_org: casa_case.casa_org)
        volunteer_2 = create(:volunteer, display_name: "Volunteer 2", casa_org: casa_case.casa_org)
        create(:case_assignment, casa_case: casa_case, volunteer: volunteer_1)
        create(:case_assignment, casa_case: casa_case, volunteer: volunteer_2, active: false, hide_old_contacts: true)
        create(:case_contact, contact_made: true, casa_case: casa_case, creator: volunteer_1, occurred_at: DateTime.now - 1)
        create(:case_contact, contact_made: true, casa_case: casa_case, creator: volunteer_2, occurred_at: DateTime.now - 1)

        visit casa_case_path(casa_case.id)

        expect(page).to have_css("#case_contacts_list .card-content", count: 2)
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

    context "when old case contacts are hidden" do
      before do
        volunteer_2 = create(:volunteer, display_name: "Volunteer 2", casa_org: casa_case.casa_org)
        create(:case_assignment, casa_case: casa_case, volunteer: volunteer_2, active: false, hide_old_contacts: true)
        create(:case_contact, contact_made: true, casa_case: casa_case, creator: volunteer_2, occurred_at: DateTime.now - 1)
      end

      it "should display only visible cases to volunteer", js: true do
        visit casa_case_path(casa_case.id)
        expect(page).to have_css("#case_contacts_list .card-content", count: 1)
      end
    end

    context "when old case contacts are displayed" do
      before do
        volunteer_2 = create(:volunteer, display_name: "Volunteer 2", casa_org: casa_case.casa_org)
        create(:case_assignment, casa_case: casa_case, volunteer: volunteer_2, active: false, hide_old_contacts: false)
        create(:case_contact, contact_made: true, casa_case: casa_case, creator: volunteer_2, occurred_at: DateTime.now - 1)
      end

      it "should display all cases to the volunteer" do
        visit casa_case_path(casa_case.id)
        expect(page).to have_css("#case_contacts_list .card-content", count: 2)
      end
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
      casa_case.case_court_orders[0].update(implementation_status: :unimplemented)

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
