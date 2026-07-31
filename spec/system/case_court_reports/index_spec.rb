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

# On casa_app the case picker is a searchable single-select TomSelect (no select2), so the
# native #case-selection is display:none; its options are asserted with visible: :all.
RSpec.shared_examples "a user with organization-level case visibility" do
  before { open_court_report_modal }

  it "shows all cases in their organization", :aggregate_failures do
    expect(page).to have_selector("#case-selection option", text: /#{Regexp.escape(unassigned_case.case_number)}/i, visible: :all)

    volunteer.casa_cases.each do |casa_case|
      expect(page).to have_selector("#case-selection option", text: /#{Regexp.escape(casa_case.case_number)}/i, visible: :all)
    end
  end

  it "hides cases from other organizations" do
    expect(page).not_to have_selector("#case-selection option", text: /#{Regexp.escape(other_org_case.case_number)}/i, visible: :all)
  end
end

RSpec.describe "case_court_reports/index", type: :system do
  context "when first arriving to 'Generate Court Report' page", :js do
    let(:volunteer) { create(:volunteer) }

    include_context "when on the court reports page", :volunteer

    it "generation modal hidden", :aggregate_failures do
      expect(page).to have_selector "#btnGenerateReport", text: "Generate report", visible: :hidden
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

    it "shows the Generate button and a searchable picker", :aggregate_failures do
      expect(page).to have_selector "#btnGenerateReport", text: "Generate report", visible: :visible
      expect(page).to have_css "#generate-docx-report-modal .ts-wrapper"
    end

    it "shows both dates empty until a case is chosen", :aggregate_failures do
      # The range belongs to a case, so neither end is filled in before one is picked. A start date
      # empty beside an end date already showing today is the asymmetry that read as broken.
      expect(page.find("#start_date").value).to eq("")
      expect(page.find("#end_date").value).to eq("")
    end

    it "empties both dates again if the case selection is cleared" do
      casa_case = casa_cases.first
      choose_typeahead_option(casa_case.case_number, select_css: "#case-selection")
      expect(page.find("#start_date").value).to be_present

      page.execute_script("document.querySelector('#case-selection').tomselect.clear()")

      expect(page.find("#start_date").value).to eq("")
      expect(page.find("#end_date").value).to eq("")
    end

    it "autofills the start date from the picked case's last hearing" do
      casa_case = casa_cases.first
      create(:court_date, casa_case: casa_case, date: 3.months.ago.to_date)
      hearing = create(:court_date, casa_case: casa_case, date: 1.month.ago.to_date)
      # The options carry each case's default, so the page has to be re-rendered after changing them.
      visit case_court_reports_path
      open_court_report_modal

      choose_typeahead_option(casa_case.case_number, select_css: "#case-selection")

      expect(page.find("#case-selection", visible: :all).value).to eq(casa_case.case_number)
      expect(page.find("#start_date").value).to eq(hearing.date.to_date.to_s)
      expect(page.find("#end_date").value).to eq(browser_today)
    end

    it "fills the end date with today when a case is chosen" do
      casa_case = casa_cases.first
      expect(page.find("#end_date").value).to eq("")

      choose_typeahead_option(casa_case.case_number, select_css: "#case-selection")

      expect(page.find("#end_date").value).to eq(browser_today)
    end

    it "falls back to the date the case was opened when it has no past hearing" do
      casa_case = casa_cases.first
      casa_case.court_dates.destroy_all
      visit case_court_reports_path
      open_court_report_modal

      choose_typeahead_option(casa_case.case_number, select_css: "#case-selection")

      expect(page.find("#case-selection", visible: :all).value).to eq(casa_case.case_number)
      expect(page.find("#start_date").value).to eq(casa_case.created_at.to_date.to_s)
    end

    it "lists all assigned cases" do
      expected_number_of_options = casa_cases.size + 1 # +1 for the prompt
      expect(page).to have_selector "#case-selection option", count: expected_number_of_options, visible: :all
    end

    it "shows correct transition status labels", :aggregate_failures do
      younger_than_transition_age = volunteer.casa_cases.reject(&:in_transition_age?).first
      at_least_transition_age = volunteer.casa_cases.detect(&:in_transition_age?)

      expect(page).to have_selector "#case-selection option", text: "#{at_least_transition_age.case_number} - transition", visible: :all
      expect(page).to have_selector "#case-selection option", text: "#{younger_than_transition_age.case_number} - non-transition", visible: :all
    end

    it "adds data-lookup attribute for volunteer searching" do
      casa_cases.each do |casa_case|
        lookup = casa_case.assigned_volunteers.map(&:display_name).join(",")
        expect(page).to have_selector "#case-selection option[data-lookup='#{lookup}']", visible: :all
      end
    end

    it "loads with no case chosen and invites a search", :aggregate_failures do
      # The native prompt stays for the no-JS render, but the control itself must read as a SEARCH
      # field: the prompt used to occupy the item slot, which parks TomSelect's input off-screen and
      # leaves no placeholder and no magnifier -- searchable, but with nothing saying so.
      expect(page).to have_selector "#case-selection option:first-of-type", text: "Select case number", visible: :all
      within "#generate-docx-report-modal" do
        expect(page).to have_no_css ".ts-control .item"
        expect(page).to have_css ".ts-control input[placeholder='Search case number']"
      end
      state = page.evaluate_script(<<~JS)
        (function () {
          const ts = document.querySelector('#case-selection').tomselect
          return {
            offscreen: ts.control_input.getBoundingClientRect().left < 0,
            magnifier: getComputedStyle(ts.wrapper.querySelector('.ts-control')).backgroundImage !== 'none'
          }
        })()
      JS
      expect(state["offscreen"]).to be false
      expect(state["magnifier"]).to be true
    end

    it "filters the case menu as you type" do
      target = casa_cases.first
      decoy = casa_cases.last
      expect(target.case_number).not_to eq(decoy.case_number)

      page.execute_script("document.querySelector('#case-selection').tomselect.focus()")
      page.driver.browser.switch_to.active_element.send_keys(target.case_number)

      # Waiting matchers: reading the menu straight after the keystrokes reads it pre-filter.
      expect(page).to have_css(".ts-dropdown .option", text: target.case_number)
      expect(page).to have_no_css(".ts-dropdown .option", text: decoy.case_number)
    end

    # One click, ONE request. src/casa_case.js kept a jQuery click handler bound to #btnGenerateReport
    # alongside the Stimulus controller, so every report was generated twice server-side and the
    # download opened in two tabs. Nothing failed -- the other example here only asserts that *a* URL
    # was opened -- so this counts.
    it "generates the report once per click" do
      casa_case = casa_cases.first
      page.execute_script(<<~JS)
        window.__generatePosts = 0
        window.__opened = []
        const originalFetch = window.fetch
        window.fetch = function (url, options) {
          if (String(url).includes('/case_court_reports/generate')) window.__generatePosts += 1
          return originalFetch.apply(this, arguments)
        }
        window.open = (url) => { window.__opened.push(url); return null }
      JS

      choose_typeahead_option(casa_case.case_number, select_css: "#case-selection")
      find("#btnGenerateReport").click

      # Same barrier as the success example: the button disables for the request and re-enables after,
      # which is the page-level signal that the round trip finished. Counting before that reads 0.
      expect(page).to have_selector "#btnGenerateReport[disabled]"
      expect(page).to have_no_selector "#btnGenerateReport[disabled]", wait: 10

      expect(page.evaluate_script("window.__opened.length")).to eq(1)
      expect(page.evaluate_script("window.__generatePosts")).to eq(1)
    end

    it "shows an error when generating without a selection" do
      within "#generate-docx-report-modal" do
        click_button "Generate report"
        expect(page).to have_selector "[data-court-report-target='error']", visible: :visible
      end
    end

    # Select via TomSelect, stub window.open to capture the download URL, wait for the button to
    # re-enable (page-level signal), then assert UI state + the opened URL.
    it "generates a report and opens the download link on success", :aggregate_failures do
      transition_case = casa_cases.detect(&:in_transition_age?)

      page.execute_script(<<~JS)
        window.__last_opened_url = null;
        window.open = function(url) { window.__last_opened_url = url; };
      JS

      within "#generate-docx-report-modal" do
        find(".ts-control").click
        find(".ts-dropdown .option[data-value='#{transition_case.case_number}']").click
        click_button "Generate report"

        expect(page).to have_selector "#btnGenerateReport[disabled]"
        expect(page).not_to have_selector "#btnGenerateReport[disabled]", wait: 10
        expect(page).to have_selector "#spinner", visible: :hidden
      end

      opened_url = page.evaluate_script("window.__last_opened_url")
      expect(opened_url).to be_present
      expect(opened_url).to match(/#{Regexp.escape(transition_case.case_number)}.*\.docx$/i)
    end
  end

  context "when the user has exactly one case", :js do
    let(:volunteer) { create(:volunteer) }
    let!(:casa_case) { create(:casa_case, casa_org: volunteer.casa_org, case_number: "ONE-0001") }
    let!(:assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case, active: true) }

    before do
      sign_in volunteer
      visit case_court_reports_path
      open_court_report_modal
    end

    # Nothing is left for a single-case volunteer to fill in: the case is chosen and both dates follow
    # from it, so the modal is ready to submit on open.
    it "preselects it and fills both dates from it", :aggregate_failures do
      expect(page.find("#case-selection", visible: :all).value).to eq("ONE-0001")
      within "#generate-docx-report-modal" do
        expect(page).to have_css ".ts-control .item", text: "ONE-0001"
      end
      expect(page.find("#start_date").value).to eq(casa_case.court_report_default_start_date.to_s)
      expect(page.find("#end_date").value).to eq(browser_today)
    end

    it "starts from the last hearing rather than the day the case was opened" do
      create(:court_date, casa_case: casa_case, date: 40.days.ago.to_date)
      visit case_court_reports_path
      open_court_report_modal

      expect(page.find("#start_date").value).to eq(40.days.ago.to_date.to_s)
    end
  end

  context "when logged in as a supervisor", :js do
    let(:volunteer) do
      create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor, display_name: "Name Last")
    end
    let(:supervisor) { volunteer.supervisor }

    include_context "when on the court reports page", :supervisor

    it "shows the searchable case picker" do
      open_court_report_modal
      expect(page).to have_css "#generate-docx-report-modal .ts-wrapper"
    end

    context "when searching for cases" do
      let(:casa_case) { volunteer.casa_cases.first }
      let(:search_term) { casa_case.case_number[-3..] }

      it "selects the correct case", :aggregate_failures do
        open_court_report_modal
        open_case_select_dropdown
        within "#generate-docx-report-modal" do
          find(".ts-control input").set(search_term)
          expect(page).to have_css(".ts-dropdown .option", text: casa_case.case_number, visible: :visible)
          find(".ts-dropdown .option", text: casa_case.case_number).click
          expect(page).to have_css(".ts-control .item", text: casa_case.case_number, visible: :visible)
        end
      end
    end
  end

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  describe "case selection visibility by user role", :js do
    let!(:volunteer_assigned_to_case) do
      create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor, display_name: "Assigned Volunteer")
    end
    let(:casa_org) { volunteer_assigned_to_case.casa_org }
    let!(:unassigned_case) { create(:casa_case, casa_org: casa_org, case_number: "UNASSIGNED-CASE-1", active: true) }
    let!(:other_org) { create(:casa_org) }
    let!(:other_org_case) { create(:casa_case, casa_org: other_org, case_number: "OTHER-ORG-CASE-99", active: true) } # rubocop:disable RSpec/LetSetup

    context "when logged in as a volunteer" do
      let(:volunteer) { volunteer_assigned_to_case }
      let!(:other_volunteer) { create(:volunteer, casa_org: volunteer.casa_org) }
      let!(:other_volunteer_case) do
        create(:casa_case, casa_org: volunteer.casa_org, case_number: "OTHER-VOL-CASE-88", volunteers: [other_volunteer], active: true)
      end

      include_context "when on the court reports page", :volunteer

      before { open_court_report_modal }

      it "shows all assigned cases", :aggregate_failures do
        volunteer.casa_cases.select(&:active?).each do |c|
          expect(page).to have_selector("#case-selection option", text: /#{Regexp.escape(c.case_number)}/i, visible: :all)
        end
      end

      it "does not show unassigned cases" do
        expect(page).not_to have_selector("#case-selection option", text: /#{Regexp.escape(unassigned_case.case_number)}/i, visible: :all)
      end

      it "does not show cases assigned to other volunteers" do
        expect(page).not_to have_selector("#case-selection option", text: /#{Regexp.escape(other_volunteer_case.case_number)}/i, visible: :all)
      end
    end

    context "when logged in as a supervisor" do
      let(:volunteer) { volunteer_assigned_to_case }
      let(:supervisor) { create(:supervisor, casa_org: volunteer.casa_org) }

      include_context "when on the court reports page", :supervisor
      it_behaves_like "a user with organization-level case visibility"
    end

    context "when logged in as an admin" do
      let(:volunteer) { volunteer_assigned_to_case }
      let(:casa_admin) { create(:casa_admin, casa_org: volunteer.casa_org) }

      include_context "when on the court reports page", :casa_admin
      it_behaves_like "a user with organization-level case visibility"
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
