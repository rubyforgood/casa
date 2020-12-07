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
      options = {text: "Generate Report"}

      expect(page).to have_selector "#btnGenerateReport", **options
    end

    it "does not see 'Download Court Report' button, which is hidden" do
      options = {text: "Download Court Report", visible: :hidden}

      expect(page).to have_selector "#btnDownloadReport", **options
    end

    it "shows a select element with default selection 'Select a case to generate report'" do
      expected_text = "Select a case to generate report"

      expect(page).to have_selector "#case-selection option[value]", text: expected_text
      expect(page).to have_select "case-selection", selected: expected_text
    end

    it "shows 3 options: 2 assigned case + 1 prompt text" do
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

  context "when choosing the prompt option (value is empty) and click on 'Generate Report' button, nothing should happen" do
    let(:option_text) { "Select a case to generate report" }

    before do
      # to find the select element, use either 'name' or 'id' attribute
      # in this case, id = "case-selection", name = "case_number"
      page.select "Select a case to generate report", from: "case-selection"
      # the above will have the same effect as the below
      # find("#case-selection").select "Select a case to generate report"
      click_button "Generate Report"
    end

    context "'Generate Report' button" do
      it "does not become disabled" do
        expect(page).not_to have_selector "#btnGenerateReport[disabled]"
      end

      it "does not have label changed to 'Court report generating. Do not refresh or leave this page'" do
        options = {text: "Court report generating. Do not refresh or leave this page"}

        expect(page).not_to have_selector "#btnGenerateReport[disabled]", **options
      end
    end

    context "'Download Court Report' button" do
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

  context "when selecting transition case, volunteer can generate and download a report" do
    let(:case_number) { casa_cases.find(&:has_transitioned?).case_number.to_s }
    let(:transition_option_text) { "#{case_number} - transition" }

    before do
      # to find the select element, use either 'name' or 'id' attribute
      # in this case, id = "case-selection", name = "case_number"
      page.select transition_option_text, from: "case-selection"
      click_button "Generate Report"
    end

    it "has transition case option selected" do
      expect(page).to have_select "case-selection", selected: transition_option_text
    end

    context "'Generate Report' button" do
      it "becomes disabled" do
        expect(page).to have_selector "#btnGenerateReport[disabled]"
      end

      it "has label changed to 'Court report generating. Do not refresh or leave this page'" do
        options = {text: "Court report generating. Do not refresh or leave this page"}

        expect(page).to have_selector "#btnGenerateReport[disabled]", **options
      end
    end

    context "'Download Court Report' button" do
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
