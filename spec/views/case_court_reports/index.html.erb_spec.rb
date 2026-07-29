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

    it "has the generate-report card" do
      expect(rendered).to have_selector("div", class: "card-style", count: 1)
    end

    it "titles the page 'Court reports' to match the nav label" do
      expect(rendered).to have_selector("h1", text: "Court reports", count: 1)
    end

    it "has a concise 'Generate report' trigger button" do
      expect(rendered).to have_selector("button[data-action='modal#open']", text: "Generate report", count: 1)
    end
  end
end
