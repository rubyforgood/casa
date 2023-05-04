require "rails_helper"

RSpec.describe "casa_cases/show", type: :view do
  let(:organization) { create(:casa_org) }
  let(:user) { create(:casa_admin, casa_org: organization) }

  before do
    enable_pundit(view, user)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_organization).and_return(user.casa_org)
  end

  context "when there is court date" do
    let!(:casa_case) { create(:casa_case, :with_upcoming_court_date, casa_org: organization, case_number: "111") }
    let(:date) { casa_case.court_dates.map(&:date).first.to_date.strftime("%B %-d, %Y") }

    before { assign(:casa_case, casa_case) }
    it "render casa case with court dates" do
      render

      expect(rendered).to match(casa_case.case_number)
      expect(rendered).to match(date)
    end

    it "render button to add court date" do
      render

      expect(rendered).to have_content("Add a court date")
    end
  end

  context "where there is no court date" do
    let!(:casa_case) { create(:casa_case, casa_org: organization, case_number: "111") }

    before { assign(:casa_case, casa_case) }
    it "render casa case without court dates" do
      render

      expect(rendered).to match(casa_case.case_number)
      expect(rendered).to have_content("No Court Dates")
    end

    it "render button to add court date" do
      render

      expect(rendered).to have_content("Add a court date")
    end
  end

  context "when there is a placement" do
    let!(:casa_case) { create(:casa_case, :with_placement, casa_org: organization, case_number: "111") }
    let(:placement_started_at) { casa_case.placements.map(&:placement_started_at).first.to_date.strftime("%B %-d, %Y") }

    before { assign(:casa_case, casa_case) }
    it "renders casa case with placements" do
      render

      expect(rendered).to match(casa_case.case_number)
      expect(rendered).to match(placement_started_at)
    end
  end

  context "where there is no placement" do
    let!(:casa_case) { create(:casa_case, casa_org: organization, case_number: "111") }

    before { assign(:casa_case, casa_case) }
    it "renders casa case without placements" do
      render

      expect(rendered).to match(casa_case.case_number)
      expect(rendered).to have_content("No Placements")
    end
  end
end
