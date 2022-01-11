require "rails_helper"

RSpec.describe "supervisors/index", type: :view do
  let(:user) {}

  before do
    enable_pundit(view, user)
    allow(view).to receive(:current_user).and_return(user)
    assign :supervisors, []
    assign :available_volunteers, []
    sign_in user
  end

  context "when logged in as an admin" do
    let(:user) { build_stubbed :casa_admin }

    it "can access the 'New Supervisor' button" do
      render template: "supervisors/index"

      expect(rendered).to have_link("New Supervisor", href: new_supervisor_path)
    end

    it "shows the legend for the colored bars at all times" do
      render template: "supervisors/index"

      expect(rendered).to match("Have attempted contact in the last 14 days")
      expect(rendered).to match("Have not attempted contact in the last 14 days")
      expect(rendered).to match("(Transition aged youth)")
    end

    xit "shows positive and negative numbers for each supervisor" do # TODO FireLemons
      supervisor = create(:supervisor)
      create(:volunteer, :with_cases_and_contacts, supervisor: supervisor)
      create(:volunteer, :with_casa_cases, supervisor: supervisor)

      assign :supervisors, [supervisor]
      render template: "supervisors/index"

      expect(rendered).to match("supervisor_indicator_positive")
      expect(rendered).to match("supervisor_indicator_negative")
      expect(rendered).to match("supervisor_indicator_transition_aged_youth")
    end

    xit "omits the positive bar if there are no active volunteers with contact w/in 14 days" do # TODO FireLemons
      supervisor = create(:supervisor)
      create(:volunteer, :with_casa_cases, supervisor: supervisor)

      assign :supervisors, [supervisor]
      render template: "supervisors/index"

      expect(rendered).not_to match("supervisor_indicator_positive")
      expect(rendered).to match("supervisor_indicator_negative")
      expect(rendered).to match("supervisor_indicator_transition_aged_youth")
    end

    xit "omits the negative bar if all volunteers have a contact within 14 days" do # TODO FireLemons
      supervisor = create(:supervisor)
      create(:volunteer, :with_cases_and_contacts, supervisor: supervisor)

      assign :supervisors, [supervisor]
      render template: "supervisors/index"

      expect(rendered).to match("supervisor_indicator_positive")
      expect(rendered).not_to match("supervisor_indicator_negative")
      expect(rendered).to match("supervisor_indicator_transition_aged_youth")
    end
  end

  context "when logged in as a supervisor" do
    let(:user) { build_stubbed :supervisor }

    it "cannot access the 'New Supervisor' button" do
      render template: "supervisors/index"

      expect(rendered).to_not have_link("New Supervisor", href: new_supervisor_path)
    end
  end
end
