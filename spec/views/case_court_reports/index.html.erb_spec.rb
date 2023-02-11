require "rails_helper"

RSpec.describe "case_court_reports/index", type: :view do
  context "Volunteer views 'Generate Court Report' form" do
    let(:user) { create(:volunteer, :with_casa_cases) }
    let(:active_assigned_cases) { CasaCase.actively_assigned_to(user) }

    before do
      allow(view).to receive(:current_user).and_return(user)
      assign :assigned_cases, active_assigned_cases
      render
    end

    it "renders the index page" do
      expect(controller.request.fullpath).to eq case_court_reports_path
    end

    it "has a card with card title 'Generate Court Report'", :aggregate_failures do
      expect(rendered).to have_selector("div", class: "card-style", count: 1)
      expect(rendered).to have_selector("h6", text: "Generate Court Report", count: 1)
    end

    it "displays a form" do
      expect(rendered).to have_selector("form", count: 1)
    end

    it "has a dropdown select with shows 2 options" do
      expect(rendered).to have_selector("select#case-selection option", count: 3)
    end

    it "has a drowndown select element for CASA case" do
      expect(rendered).to have_selector("select#case-selection")
    end

    it "has a 'Generate Report' button" do
      expect(rendered).to have_selector("button[@type='submit']", text: "Generate Report", id: "btnGenerateReport")
    end

    it "has a 'Spinner' button" do
      expect(rendered).to have_selector("i#spinner")
    end
  end
end
