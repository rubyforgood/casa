require "rails_helper"

RSpec.describe "casa_cases/show", type: :view do
  let(:user) { create(:casa_admin) }

  before do
    enable_pundit(view, user)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_organization).and_return(user.casa_org)
  end

  context "when there is court date" do
    it "renders casa case with court dates" do
      casa_case = create(:casa_case, case_number: "111")
      create(:court_date, casa_case: casa_case, date: Date.new(2023, 5, 6))

      assign(:casa_case, casa_case)
      render

      expect(rendered).to match("111")
      expect(rendered).to match("May 6, 2023")
    end

    it "render button to add court date" do
      casa_case = create(:casa_case)
      assign(:casa_case, casa_case)

      render

      expect(rendered).to have_content("Add a court date")
    end
  end

  context "where there is no court date" do
    it "render casa case without court dates" do
      casa_case = create(:casa_case)
      assign(:casa_case, casa_case)

      render

      expect(rendered).to match(casa_case.case_number)
      expect(rendered).to have_content("No Court Dates")
    end

    it "render button to add court date" do
      casa_case = create(:casa_case)
      assign(:casa_case, casa_case)

      render

      expect(rendered).to have_content("Add a court date")
    end
  end

  context "when there is a placement" do
    it "renders casa case with placements" do
      casa_case = create(:casa_case, case_number: "111")
      create(:placement, casa_case: casa_case, placement_started_at: Date.new(2023, 5, 6))

      assign(:casa_case, casa_case)
      render

      expect(rendered).to match("111")
      expect(rendered).to match("Current Placement:")
      expect(rendered).to match(/Placement Type/)
      expect(rendered).to match("Placed since: May 6, 2023")
      expect(rendered).to match("See All Placements")
    end
  end

  context "where there is no placement" do
    it "renders casa case without placements" do
      casa_case = create(:casa_case)
      assign(:casa_case, casa_case)

      render

      expect(rendered).to match(casa_case.case_number)
      expect(rendered).to have_content("Current Placement:")
      expect(rendered).to have_content("Unknown")
      expect(rendered).to have_content("See All Placements")
    end
  end
end
