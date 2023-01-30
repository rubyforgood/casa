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

        parsed_html = Nokogiri.HTML5(rendered)

        expect(parsed_html.css("#supervisors .supervisor_case_contact_stats .attempted-contact").length).to eq(1)
        expect(parsed_html.css("#supervisors .supervisor_case_contact_stats .no-attempted-contact").length).to eq(1)
      end

      it "accurately displays the number of active and inactive volunteers per supervisor" do
        create(:volunteer, :with_cases_and_contacts, supervisor: supervisor)
        assign :supervisors, [supervisor]
        render template: "supervisors/index"

        parsed_html = Nokogiri.HTML5(rendered)

        active_bar = parsed_html.css("#supervisors .supervisor_case_contact_stats .attempted-contact")
        inactive_bar = parsed_html.css("#supervisors .supervisor_case_contact_stats .no-attempted-contact")
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
        render template: "supervisors/index"

        parsed_html = Nokogiri.HTML5(rendered)

        expect(parsed_html.css("#supervisors .supervisor_case_contact_stats .attempted-contact").length).to eq(0)
        expect(parsed_html.css("#supervisors .supervisor_case_contact_stats .no-attempted-contact").length).to eq(1)
      end
    end

    context "when a supervisor only has volunteers who have submitted a case contact in 14 days" do
      let(:supervisor) { create(:supervisor) }
      let!(:volunteer_with_recently_created_contacts) {
        create(:volunteer, :with_cases_and_contacts, supervisor: supervisor)
      }

      it "shows the end of the attempted contact bar instead of the no attempted contact bar" do
        assign :supervisors, [supervisor]
        render template: "supervisors/index"

        parsed_html = Nokogiri.HTML5(rendered)

        expect(parsed_html.css("#supervisors .supervisor_case_contact_stats .attempted-contact").length).to eq(1)
        expect(parsed_html.css("#supervisors .supervisor_case_contact_stats .attempted-contact-end").length).to eq(1)
        expect(parsed_html.css("#supervisors .supervisor_case_contact_stats .no-attempted-contact").length).to eq(0)
      end
    end

    context "when a supervisor does not have volunteers" do
      let(:supervisor) { create(:supervisor) }

      it "shows a no assigned volunteers message instead of attempted and no attempted contact bars" do
        assign :supervisors, [supervisor]
        render template: "supervisors/index"

        parsed_html = Nokogiri.HTML5(rendered)

        expect(parsed_html.css("#supervisors .supervisor_case_contact_stats .attempted-contact").length).to eq(0)
        expect(parsed_html.css("#supervisors .supervisor_case_contact_stats .no-attempted-contact").length).to eq(0)
        expect(parsed_html.css("#supervisors .supervisor_case_contact_stats .no-volunteers").length).to eq(1)
      end
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
