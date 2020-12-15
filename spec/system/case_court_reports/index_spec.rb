require "rails_helper"

RSpec.describe "case_court_reports/index", type: :system do
  let(:volunteer) { create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor) }
  let(:casa_cases) { CasaCase.actively_assigned_to(volunteer) }

  before do
    sign_in volunteer
    visit case_court_reports_path
  end

  context "when first arriving to 'Generate Court Report' page, by default" do
    it "sees 'Generate Report' button" do
      options = {text: "Generate Report", visible: true}

      expect(page).to have_selector "#btnGenerateReport", **options
    end

    it "has 'Download Court Report' button with Bootstrap class '.d-none'" do
      options = {text: "Download Court Report", class: ["d-none"]}

      expect(page).to have_selector "#btnDownloadReport", **options
    end

    it "shows a select element with default selection 'Select a case to generate report'" do
      expected_text = "Select a case to generate report"
      find("#case-selection").click.first("option", text: expected_text).select_option

      expect(page).to have_selector "#case-selection option:first-of-type", text: expected_text
      expect(page).to have_select "case-selection", selected: expected_text
    end

    it "shows n+1 options in total, e.g 3 options <- 2 assigned cases + 1 prompt text" do
      expected_number_of_options = casa_cases.size + 1

      expect(page).to have_selector "#case-selection option", count: expected_number_of_options
    end

    it "shows transition stamp for transitioned case" do
      expected_text = "#{casa_cases.second.case_number} - transition"

      expect(page).to have_selector "#case-selection option", text: expected_text
    end

    it "shows non-transition stamp for non-transitioned case" do
      expected_text = "#{casa_cases.first.case_number} - non-transition"

      expect(page).to have_selector "#case-selection option", text: expected_text
    end
  end

  context "when choosing the prompt option (value is empty) and click on 'Generate Report' button, nothing should happen", js: true do
    let(:option_text) { "Select a case to generate report" }

    before do
      # to find the select element, use either 'name' or 'id' attribute
      # in this case, id = "case-selection", name = "case_number"
      page.select "Select a case to generate report", from: "case-selection"
      # the above will have the same effect as the below
      # find("#case-selection").select "Select a case to generate report"
      click_button "Generate Report"
    end

    describe "'Generate Report' button" do
      it "does not become disabled" do
        expect(page).not_to have_selector "#btnGenerateReport[disabled]"
      end

      it "does not have label changed to 'Court report generating. Do not refresh or leave this page'" do
        options = {text: "Court report generating. Do not refresh or leave this page"}

        expect(page).not_to have_selector "#btnGenerateReport[disabled]", **options
      end
    end

    describe "'Download Court Report' button" do
      it "does not become visible" do
        options = {text: "Download Court Report", visible: :hidden}

        expect(page).to have_selector "#btnDownloadReport", **options
      end

      it "does not change href value from '#'" do
        options = {id: "btnDownloadReport", visible: :hidden, href: "#"}

        expect(page).to have_link "Download Court Report", **options
      end
    end
  end

  describe "'Case Number' dropdown list", js: true do
    let(:transitioned_case_number) { casa_cases.find(&:has_transitioned?).case_number.to_s }
    let(:transitioned_option_text) { "#{transitioned_case_number} - transition" }
    let(:non_transitioned_case_number) { casa_cases.reject(&:has_transitioned?).first.case_number.to_s }
    let(:non_transitioned_option_text) { "#{non_transitioned_case_number} - non-transition" }

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

  context "when selecting a case, volunteer can generate and download a report", js: true do
    let(:case_number) { casa_cases.find(&:has_transitioned?).case_number.to_s }
    let(:option_text) { "#{case_number} - transition" }

    before do
      # to find the select element, use either 'name' or 'id' attribute
      # in this case, id = "case-selection", name = "case_number"
      page.select option_text, from: "case-selection"
      click_button "Generate Report"
    end

    describe "'Generate Report' button" do
      it "becomes disabled" do
        expect(page).to have_selector "#btnGenerateReport[disabled]"
      end

      it "has label changed to 'Court report generating. Do not refresh or leave this page'" do
        options = {text: "Court report generating. Do not refresh or leave this page"}

        expect(page).to have_selector "#btnGenerateReport[disabled]", **options
      end
    end

    describe "'Download Court Report' button" do
      it "becomes visible" do
        options = {text: "Download Court Report", visible: :visible}

        expect(page).to have_selector "#btnDownloadReport", **options
      end

      it "changes href value from '#' to a link with .docx format" do
        download_link = "/case_court_reports/#{case_number}.docx"

        options = {id: "btnDownloadReport", visible: :visible, href: download_link}

        expect(page).to have_link "Download Court Report", **options
      end
    end
  end
end
