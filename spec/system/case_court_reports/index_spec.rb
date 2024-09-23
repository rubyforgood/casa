require "rails_helper"

RSpec.describe "case_court_reports/index", type: :system do
  let(:volunteer) { create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor, display_name: "Name Last") }
  let(:supervisor) { volunteer.supervisor }
  let(:casa_cases) { CasaCase.actively_assigned_to(volunteer) }
  let(:younger_than_transition_age) { volunteer.casa_cases.reject(&:in_transition_age?).first }
  let(:at_least_transition_age) { volunteer.casa_cases.find(&:in_transition_age?) }
  let(:modal_selector) { '[data-bs-target="#generate-docx-report-modal"]' }

  before do
    travel_to Date.new(2021, 1, 1)
    sign_in volunteer
    visit case_court_reports_path
  end
  after { travel_back }

  context "when first arriving to 'Generate Court Report' page", js: true do
    it "generation modal hidden" do
      expect(page).to have_selector "#btnGenerateReport", text: "Generate Report", visible: false
      expect(page).to have_selector "#case-selection", visible: false
      expect(page).not_to have_selector ".select2"
    end
  end

  context "after opening 'Download Court Report' modal", js: true do
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

      # shows n+1 options in total, e.g 3 options <- 2 assigned cases + 1 prompt text
      expected_number_of_options = casa_cases.size + 1
      expect(page).to have_selector "#case-selection option", count: expected_number_of_options

      # shows transition stamp for transitioned case
      expected_text = "#{at_least_transition_age.case_number} - transition"
      expect(page).to have_selector "#case-selection option", text: expected_text

      # adds data-lookup attribute for searching by volunteer name
      casa_cases.each do |casa_case|
        lookup = casa_case.assigned_volunteers.map(&:display_name).join(",")
        expect(page).to have_selector "#case-selection option[data-lookup='#{lookup}']"
      end

      # shows non-transition stamp for non-transitioned case
      expected_text = "#{younger_than_transition_age.case_number} - non-transition"
      expect(page).to have_selector "#case-selection option", text: expected_text

      # shows a select element with default selection 'Select case number'
      expected_text = "Select case number"
      find("#case-selection").click.first("option", text: expected_text).select_option

      expect(page).to have_selector "#case-selection option:first-of-type", text: expected_text
      expect(page).to have_select "case-selection", selected: expected_text

      # when choosing the prompt option (value is empty) and click on 'Generate Report' button, nothing should happen"
      # should have disabled generate button, download icon and no spinner
      page.select "Select case number", from: "case-selection"
      click_button "Generate Report"

      expect(page).to have_selector("#btnGenerateReport .lni-download", visible: true)
      expect(page).to_not have_selector("#btnGenerateReport[disabled]")
      expect(page).to have_selector("#spinner", visible: :hidden)
    end
  end

  describe "'Case Number' dropdown list", js: true do
    let(:transitioned_case_number) { casa_cases.find(&:in_transition_age?).case_number.to_s }
    let(:transitioned_option_text) { "#{transitioned_case_number} - transition(assigned to Name Last)" }
    let(:non_transitioned_case_number) { casa_cases.reject(&:in_transition_age?).first.case_number.to_s }
    let(:non_transitioned_option_text) { "#{non_transitioned_case_number} - non-transition(assigned to Name Last)" }

    it "has transition case option selected" do
      page.find(modal_selector).click
      page.select transitioned_option_text, from: "case-selection"

      click_button "Generate Report"

      expect(page).to have_select "case-selection", selected: transitioned_option_text
    end

    it "has non-transitioned case option selected" do
      page.find(modal_selector).click
      page.select non_transitioned_option_text, from: "case-selection"

      click_button "Generate Report"

      expect(page).to have_select "case-selection", selected: non_transitioned_option_text
    end
  end

  context "when selecting a case, volunteer can generate and download a report", js: true do
    let(:casa_case) { casa_cases.find(&:in_transition_age?) }
    let(:option_text) { "#{casa_case.case_number} - transition" }

    before do
      page.find(modal_selector).click
      # to find the select element, use either 'name' or 'id' attribute
      # in this case, id = "case-selection", name = "case_number"
      page.select option_text, from: "case-selection"

      @download_window = window_opened_by do
        click_button "Generate Report"
      end
    end

    describe "when court report status is not 'submitted'" do
      before do
        casa_case.update!(court_report_status: :in_review)
      end

      it "does not allow supervisors to download already generated report from case details page" do
        supervisor = build(:supervisor, casa_org: volunteer.casa_org)

        sign_out volunteer
        sign_in supervisor

        visit casa_case_path(casa_case.id)

        expect(page).not_to have_link("Click to download")
      end

      it "does not allow admins to download already generated report from case details page" do
        casa_admin = build(:casa_admin)

        sign_out volunteer
        sign_in casa_admin

        visit casa_case_path(casa_case.id)

        expect(page).not_to have_link("Click to download")
      end
    end

    describe "when court report status is 'submitted'" do
      before do
        casa_case.update!(court_report_status: :submitted)
      end

      it "allows supervisors to download already generated report from case details page" do
        supervisor = build(:supervisor, casa_org: volunteer.casa_org)

        sign_out volunteer
        sign_in supervisor

        visit casa_case_path(casa_case.id)

        expect(page).to have_link("Click to download")
      end

      it "allows admins to download already generated report from case details page" do
        casa_admin = build(:casa_admin)

        sign_out volunteer
        sign_in casa_admin

        visit casa_case_path(casa_case.id)

        expect(page).to have_link("Click to download")
      end
    end
  end

  # TODO: make this a request spec
  describe "as a supervisor" do
    before do
      sign_in supervisor
      visit case_court_reports_path
    end

    it { expect(page).to have_selector ".select2" }
    it { expect(page).to have_text "Search by volunteer name or case number" }

    context "when searching for cases" do
      let(:casa_case) { volunteer.casa_cases.first }
      let(:search_term) { casa_case.case_number[-3..] }

      it "selects the correct case", js: true do
        find(modal_selector).click

        find("#case_select_body .selection").click
        send_keys(search_term)
        send_keys :enter

        expect(page).to have_css(".select2-selection__rendered", text: casa_case.case_number)
      end
    end
  end
end
