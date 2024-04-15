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
      expect(rendered).to have_selector("h6", text: "Court Reports", count: 1)
      expect(rendered).to have_selector("div", class: "card-style", count: 1)
    end

    it "page has title 'Gererate Reports'" do
      expect(rendered).to have_selector("h1", text: "Generate Reports", count: 1)
    end

    it "has button with 'Download Court Report as .docx' text" do
      expect(rendered).to have_selector("button", text: /Download Court Report as \.docx/i, count: 1)
    end
  end
end
