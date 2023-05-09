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
    let!(:casa_cases) { create_list(:casa_case, 2, court_dates: []) }

    it "can access the 'New Supervisor' button" do
      assign :casa_cases, casa_cases
      render template: "supervisors/index"

      expect(rendered).to have_link("New Supervisor", href: new_supervisor_path)
    end

    it "show casa_cases list" do
      assign :supervisors, []
      assign :casa_cases, casa_cases
      render template: "supervisors/index"

      casa_cases.each do |casa_case|
        expect(rendered).to have_text(casa_case.case_number)
        expect(rendered).to have_text(casa_case.hearing_type_name)
        expect(rendered).to have_text(casa_case.judge_name)
        expect(rendered).to have_text(casa_case.decorate.status)
        expect(rendered).to have_text(casa_case.decorate.transition_aged_youth)
      end
    end
  end

  context "when logged in as a supervisor" do
    let(:user) { build_stubbed :supervisor }
    let!(:casa_cases) { create_list(:casa_case, 2, court_dates: []) }

    it "cannot access the 'New Supervisor' button" do
      assign :casa_cases, casa_cases
      render template: "supervisors/index"

      expect(rendered).to_not have_link("New Supervisor", href: new_supervisor_path)
    end
  end
end
