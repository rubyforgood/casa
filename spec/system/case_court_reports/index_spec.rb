require "rails_helper"

RSpec.describe "case_court_reports/index", type: :system do
  let(:volunteer) { create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor, display_name: "Name Last") }
  let(:supervisor) { volunteer.supervisor }
  let(:casa_cases) { CasaCase.actively_assigned_to(volunteer) }
  let(:younger_than_transition_age) { volunteer.casa_cases.reject(&:in_transition_age?).first }
  let(:at_least_transition_age) { volunteer.casa_cases.find(&:in_transition_age?) }

  before do
    sign_in volunteer
    visit case_court_reports_path
  end

  context "when first arriving to 'Generate Court Report' page" do
    it "sees 'Generate Report' button" do
      options = {text: "Generate Report", visible: true}

      expect(page).to have_selector "#btnGenerateReport", **options
    end

    it { expect(page).not_to have_selector ".select2" }

    it "shows a select element with default selection 'Select case number'" do
      expected_text = "Select case number"
      find("#case-selection").click.first("option", text: expected_text).select_option

      expect(page).to have_selector "#case-selection option:first-of-type", text: expected_text
      expect(page).to have_select "case-selection", selected: expected_text
    end

    it "shows n+1 options in total, e.g 3 options <- 2 assigned cases + 1 prompt text" do
      expected_number_of_options = casa_cases.size + 1

      expect(page).to have_selector "#case-selection option", count: expected_number_of_options
    end

    it "shows transition stamp for transitioned case" do
      expected_text = "#{at_least_transition_age.case_number} - transition"

      expect(page).to have_selector "#case-selection option", text: expected_text
    end

    it "shows non-transition stamp for non-transitioned case" do
      expected_text = "#{younger_than_transition_age.case_number} - non-transition"

      expect(page).to have_selector "#case-selection option", text: expected_text
    end

    it "adds data-lookup attribute for searching by volunteer name" do
      casa_cases.each do |casa_case|
        lookup = casa_case.assigned_volunteers.map(&:display_name).join(",")
        expect(page).to have_selector "#case-selection option[data-lookup='#{lookup}']"
      end
    end
  end

  context "when choosing the prompt option (value is empty) and click on 'Generate Report' button, nothing should happen", js: true do
    let(:option_text) { "Select case number" }

    before do
      # to find the select element, use either 'name' or 'id' attribute
      # in this case, id = "case-selection", name = "case_number"
      page.select "Select case number", from: "case-selection"
      # the above will have the same effect as the below
      # find("#case-selection").select "Select case number"
      click_button "Generate Report"
    end

    describe "'Generate Report' button" do
      it "does not become disabled" do
        expect(page).not_to have_selector "#btnGenerateReport[disabled]"
      end
    end

    describe "Spinner" do
      it "does not become visible" do
        options = {visible: :hidden}

        expect(page).to have_selector "#spinner", **options
      end
    end
  end

  describe "'Case Number' dropdown list", js: true do
    let(:transitioned_case_number) { casa_cases.find(&:in_transition_age?).case_number.to_s }
    let(:transitioned_option_text) { "#{transitioned_case_number} - transition(assigned to Name Last)" }
    let(:non_transitioned_case_number) { casa_cases.reject(&:in_transition_age?).first.case_number.to_s }
    let(:non_transitioned_option_text) { "#{non_transitioned_case_number} - non-transition(assigned to Name Last)" }

    it "has transition case option selected" do
      page.select transitioned_option_text, from: "case-selection"

      click_button "Generate Report"

      expect(page).to have_select "case-selection", selected: transitioned_option_text
    end

    it "has non-transitioned case option selected" do
      page.select non_transitioned_option_text, from: "case-selection"

      click_button "Generate Report"

      expect(page).to have_select "case-selection", selected: non_transitioned_option_text
    end
  end

  context "when generating a report, volunteer sees waiting page", js: true do
    let(:casa_case) { casa_cases.find(&:in_transition_age?) }
    let(:option_text) { "#{casa_case.case_number} - transition" }

    before do
      # to find the select element, use either 'name' or 'id' attribute
      # in this case, id = "case-selection", name = "case_number"
      page.select option_text, from: "case-selection"
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

  context "when selecting a case, volunteer can generate and download a report", js: true do
    let(:casa_case) { casa_cases.find(&:in_transition_age?) }
    let(:option_text) { "#{casa_case.case_number} - transition" }

    before do
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
        page.find("span.selection").click
        page.find(".select2-search__field").click

        send_keys(search_term)
        send_keys :enter

        expect(find(".select2-selection__rendered").text).to match(/^#{casa_case.case_number}/)
      end
    end
  end
end
