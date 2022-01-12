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

    context "when a supervisor has volunteers who have and have not submitted a case contact in 14 days" do
      let(:supervisor) { create(:supervisor) }
      let!(:volunteer_with_recently_created_contacts) {
        create(:volunteer, :with_cases_and_contacts, supervisor: supervisor)
      }
      let!(:volunteer_without_recently_created_contacts) {
        create(:volunteer, :with_casa_cases, supervisor: supervisor)
      }

      it "shows positive and negative numbers" do
        assign :supervisors, [supervisor]
        render template: "supervisors/index"

        PARSED_HTML = Nokogiri.HTML5(rendered)

        expect(PARSED_HTML.css("#supervisors .supervisor_case_contact_stats .no-attempted-contact").length).to equal(1)
        expect(PARSED_HTML.css("#supervisors .supervisor_case_contact_stats .attempted-contact").length).to equal(1)
      end
    end

    context "when a supervisor only has volunteers who have not submitted a case contact in 14 days" do
      let(:supervisor) { create(:supervisor) }
      let!(:volunteer_without_recently_created_contacts) {
        create(:volunteer, :with_casa_cases, supervisor: supervisor)
      }

      it "omits the positive bar" do
        assign :supervisors, [supervisor]
        render template: "supervisors/index"

        PARSED_HTML = Nokogiri.HTML5(rendered)

        expect(PARSED_HTML.css("#supervisors .supervisor_case_contact_stats .no-attempted-contact").length).to equal(1)
        expect(PARSED_HTML.css("#supervisors .supervisor_case_contact_stats .attempted-contact").length).to equal(0)
      end
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
