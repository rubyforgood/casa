# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  config.include CaseCourtReportHelpers, type: :system
end

RSpec.shared_context "when on the court reports page" do |user_role|
  let(:current_user) { send(user_role) }

  before do
    sign_in current_user
    visit case_court_reports_path
  end
end

RSpec.shared_examples "a user with organization-level case visibility in autocomplete" do
  before do
    open_court_report_modal
    open_case_select2_dropdown
  end

  it "shows all cases in their organization", :aggregate_failures do
    # Ensure the dropdown results area is ready
    expect(page).to have_css("ul.select2-results__options")

    # Check for the unassigned case created in the calling context
    expect(page).to have_css(".select2-results__option", text: /#{Regexp.escape(unassigned_case.case_number)}/i)

    # Check for each case assigned to the volunteer (created in the calling context)
    volunteer.casa_cases.each do |casa_case|
      # Use regex to flexibly match text format (e.g., "CASE-NUM - status(assigned...)")
      expect(page).to have_css(".select2-results__option", text: /#{Regexp.escape(casa_case.case_number)}/i)
    end
  end

  it "hides cases from other organizations", :aggregate_failures do
    # Find and interact with the search field
    input_field = find("input.select2-search__field", visible: :all)
    input_field.click # Ensure focus before typing
    input_field.send_keys(other_org_case.case_number)

    # Assert that "No results found" IS visible (Capybara waits)
    expect(page).to have_css(".select2-results__option", text: "No results found", visible: :visible, wait: 5)

    # Assert that the specific other org case number is NOT visible
    expect(page).not_to have_css(".select2-results__option", text: other_org_case.case_number, visible: :visible)
  end
end

RSpec.describe "case_court_reports/index", type: :system do
  context "when first arriving to 'Generate Court Report' page", :js do
    let(:volunteer) { create(:volunteer) }

    include_context "when on the court reports page", :volunteer

    it "generation modal hidden", :aggregate_failures do
      expect(page).to have_selector "#btnGenerateReport", text: "Generate Report", visible: :hidden
      expect(page).to have_selector "#case-selection", visible: :hidden
      expect(page).not_to have_selector ".select2"
    end
  end

  context "when opening 'Download Court Report' modal", :js do
    let(:volunteer) do
      create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor, display_name: "Volunteer")
    end
    let(:supervisor) { volunteer.supervisor }
    let(:casa_cases) { CasaCase.actively_assigned_to(volunteer) }

    include_context "when on the court reports page", :volunteer

    before do
      open_court_report_modal
    end

    it "shows the Generate button", :aggregate_failures do
      expect(page).to have_selector "#btnGenerateReport", text: "Generate Report", visible: :visible
      expect(page).not_to have_selector ".select2"
    end

    it "shows correct default dates", :aggregate_failures do
      date = Date.current
      formatted_date = date.strftime("%B %d, %Y") # January 01, 2021

      expect(page.find("#start_date").value).to eq(formatted_date)
      expect(page.find("#end_date").value).to eq(formatted_date)
    end

    it "lists all assigned cases" do
      expected_number_of_options = casa_cases.size + 1 # +1 for "Select case"
      expect(page).to have_selector "#case-selection option", count: expected_number_of_options
    end

    it "shows correct transition status labels", :aggregate_failures do # rubocop:disable RSpec/ExampleLength
      younger_than_transition_age = volunteer.casa_cases.reject(&:in_transition_age?).first
      at_least_transition_age = volunteer.casa_cases.detect(&:in_transition_age?)

      expected_text_transition = "#{at_least_transition_age.case_number} - transition"
      expect(page).to have_selector "#case-selection option", text: expected_text_transition

      expected_text_non_transition = "#{younger_than_transition_age.case_number} - non-transition"
      expect(page).to have_selector "#case-selection option", text: expected_text_non_transition
    end

    it "adds data-lookup attribute for volunteer searching" do
      casa_cases.each do |casa_case|
        lookup = casa_case.assigned_volunteers.map(&:display_name).join(",")
        expect(page).to have_selector "#case-selection option[data-lookup='#{lookup}']"
      end
    end

    it "defaults to 'Select case number' prompt", :aggregate_failures do
      expect(page).to have_select "case-selection", selected: "Select case number"
      # Extra check for the first option specifically
      expect(page).to have_selector "#case-selection option:first-of-type", text: "Select case number"
    end

    it "shows an error when generating without a selection", :aggregate_failures do # rubocop:disable RSpec/ExampleLength
      # Ensure default is selected
      page.select "Select case number", from: "case-selection"
      click_button "Generate Report"

      expect(page).to have_selector(".select-required-error", visible: :visible)
      # Check button state remains unchanged (not disabled, spinner hidden)
      expect(page).to have_selector("#btnGenerateReport .lni-download", visible: :visible)
      expect(page).not_to have_selector("#btnGenerateReport[disabled]")
      expect(page).to have_selector("#spinner", visible: :hidden)
    end

    it "hides the error when a valid case is selected", :aggregate_failures do
      click_button "Generate Report" # First, make the error appear
      expect(page).to have_selector(".select-required-error", visible: :visible)

      test_case_number = casa_cases.detect(&:in_transition_age?).case_number.to_s
      page.select test_case_number, from: "case-selection"
      expect(page).not_to have_selector(".select-required-error", visible: :visible)
    end

    it "clears the error message when the modal is reopened", :aggregate_failures do
      click_button "Generate Report" # Make error appear
      expect(page).to have_selector(".select-required-error", visible: :visible)

      click_button "Close"
      open_court_report_modal # Reopen using the helper
      expect(page).not_to have_selector(".select-required-error", visible: :visible) # Error should be gone
    end
  end

  context "when logged in as a supervisor" do
    let(:volunteer) do
      create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor, display_name: "Name Last")
    end
    let(:supervisor) { volunteer.supervisor }

    include_context "when on the court reports page", :supervisor

    it { expect(page).to have_selector ".select2" }
    it { expect(page).to have_text "Search by volunteer name or case number" }

    context "when searching for cases" do
      let(:casa_case) { volunteer.casa_cases.first }
      let(:search_term) { casa_case.case_number[-3..] }

      it "selects the correct case", :aggregate_failures, :js do # rubocop:disable RSpec/ExampleLength
        open_court_report_modal
        open_case_select2_dropdown
        send_keys(search_term)
        # Wait for the search result to appear in the dropdown
        expect(page).to have_css(".select2-results__option", text: casa_case.case_number, visible: :visible)
        # Click the result instead of sending enter
        find(".select2-results__option", text: casa_case.case_number).click
        # Wait for selection to update
        expect(page).to have_css(".select2-selection__rendered", text: casa_case.case_number, visible: :visible)
      end
    end
  end

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  describe "case selection visibility by user role", :js do
    let!(:volunteer_assigned_to_case) do
      create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor, display_name: "Assigned Volunteer")
    end
    let(:casa_org) { volunteer_assigned_to_case.casa_org } # Derive org from the volunteer
    let!(:unassigned_case) { create(:casa_case, casa_org: casa_org, case_number: "UNASSIGNED-CASE-1", active: true) }
    let!(:other_org) { create(:casa_org) }
    let!(:other_org_case) { create(:casa_case, casa_org: other_org, case_number: "OTHER-ORG-CASE-99", active: true) } # rubocop:disable RSpec/LetSetup

    context "when logged in as a volunteer" do
      let(:volunteer) { volunteer_assigned_to_case }
      let!(:other_volunteer) { create(:volunteer, casa_org: volunteer.casa_org) }
      let!(:other_volunteer_case) do
        create(:casa_case, casa_org: volunteer.casa_org, case_number: "OTHER-VOL-CASE-88", volunteers: [other_volunteer],
          active: true)
      end

      include_context "when on the court reports page", :volunteer

      before do
        open_court_report_modal
      end

      it "shows all assigned cases in autocomplete search", :aggregate_failures do
        volunteer.casa_cases.select(&:active?).each do |c|
          expect(page).to have_selector("#case-selection option", text: /#{Regexp.escape(c.case_number)}/i)
        end
      end

      it "does not show unassigned cases in autocomplete search" do
        expect(page).not_to have_selector("#case-selection option",
          text: /#{Regexp.escape(unassigned_case.case_number)}/i)
      end

      it "does not show cases assigned to other volunteers in autocomplete search" do
        expect(page).not_to have_selector("#case-selection option",
          text: /#{Regexp.escape(other_volunteer_case.case_number)}/i)
      end
    end

    context "when logged in as a supervisor" do
      let(:volunteer) { volunteer_assigned_to_case }
      let(:supervisor) { create(:supervisor, casa_org: volunteer.casa_org) }

      include_context "when on the court reports page", :supervisor
      it_behaves_like "a user with organization-level case visibility in autocomplete"
    end

    context "when logged in as an admin" do
      let(:volunteer) { volunteer_assigned_to_case }
      let(:casa_admin) { create(:casa_admin, casa_org: volunteer.casa_org) }

      include_context "when on the court reports page", :casa_admin
      it_behaves_like "a user with organization-level case visibility in autocomplete"
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
