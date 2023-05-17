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
        assign :casa_cases, casa_cases
        render template: "supervisors/index"

        parsed_html = Nokogiri.HTML5(rendered)

        expect(parsed_html.css("#supervisors .success-bg").length).to eq(1)
        expect(parsed_html.css("#supervisors .danger-bg").length).to eq(1)
      end

      it "accurately displays the number of active and inactive volunteers per supervisor" do
        create(:volunteer, :with_cases_and_contacts, supervisor: supervisor)
        assign :supervisors, [supervisor]
        assign :casa_cases, casa_cases
        render template: "supervisors/index"

        parsed_html = Nokogiri.HTML5(rendered)

        active_bar = parsed_html.css("#supervisors .success-bg")
        inactive_bar = parsed_html.css("#supervisors .danger-bg")
        active_flex = active_bar.inner_html
        inactive_flex = inactive_bar.inner_html
        active_content = active_bar.children[0].text.strip
        inactive_content = inactive_bar.children[0].text.strip

        expect(active_flex).to eq(active_content)
        expect(inactive_flex).to eq(inactive_content)
        expect(active_flex.to_i).to eq(2)
        expect(inactive_flex.to_i).to eq(1)
      end
    end

    context "when a supervisor only has volunteers who have not submitted a case contact in 14 days" do
      let(:supervisor) { create(:supervisor) }
      let!(:volunteer_without_recently_created_contacts) {
        create(:volunteer, :with_casa_cases, supervisor: supervisor)
      }

      it "omits the attempted contact stat bar" do
        assign :supervisors, [supervisor]
        assign :casa_cases, casa_cases
        render template: "supervisors/index"

        parsed_html = Nokogiri.HTML5(rendered)

        expect(parsed_html.css("#supervisors .success-bg").length).to eq(0)
        expect(parsed_html.css("#supervisors .danger-bg").length).to eq(1)
      end
    end

    context "when a supervisor only has volunteers who have submitted a case contact in 14 days" do
      let(:supervisor) { create(:supervisor) }
      let!(:volunteer_with_recently_created_contacts) {
        create(:volunteer, :with_cases_and_contacts, supervisor: supervisor)
      }

      it "shows the end of the attempted contact bar instead of the no attempted contact bar" do
        assign :supervisors, [supervisor]
        assign :casa_cases, casa_cases
        render template: "supervisors/index"

        parsed_html = Nokogiri.HTML5(rendered)

        expect(parsed_html.css("#supervisors .success-bg").length).to eq(1)
        expect(parsed_html.css("#supervisors .danger-bg").length).to eq(0)
      end
    end

    context "when a supervisor does not have volunteers" do
      let(:supervisor) { create(:supervisor) }

      it "shows a no assigned volunteers message instead of attempted and no attempted contact bars" do
        assign :supervisors, [supervisor]
        assign :casa_cases, casa_cases
        render template: "supervisors/index"

        parsed_html = Nokogiri.HTML5(rendered)

        expect(parsed_html.css("#supervisors .success-bg").length).to eq(0)
        expect(parsed_html.css("#supervisors .danger-bg").length).to eq(0)
        expect(parsed_html.css("#supervisors .bg-secondary").length).to eq(1)

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
