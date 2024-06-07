require "rails_helper"

RSpec.describe "supervisors/index", type: :view do
  context "when logged in as an admin" do
    it "can access the 'New Supervisor' button" do
      user = create(:casa_admin)
      enable_pundit(view, user)
      casa_cases = create_list(:casa_case, 2, court_dates: [])
      assign :casa_cases, casa_cases
      assign :supervisors, []
      assign :available_volunteers, []

      sign_in user

      render template: "supervisors/index"

      expect(rendered).to have_link("New Supervisor", href: new_supervisor_path)
    end

    it "show casa_cases list" do
      user = create(:casa_admin)
      enable_pundit(view, user)
      casa_case1 = create(:casa_case,
        case_number: "123",
        active: true,
        birth_month_year_youth: "1999-01-01".to_date)
      casa_case2 = create(:casa_case,
        case_number: "456",
        active: false,
        birth_month_year_youth: "2024-01-01".to_date)
      assign :casa_cases, [casa_case1, casa_case2]
      assign :supervisors, []
      assign :available_volunteers, []

      sign_in user
      render template: "supervisors/index"

      expect(rendered).to have_text "123"
      expect(rendered).to have_text "Active"
      expect(rendered).to have_text "Yes #{CasaCase::TRANSITION_AGE_YOUTH_ICON}"

      expect(rendered).to have_text "456"
      expect(rendered).to have_text "Inactive"
      expect(rendered).to have_text "No #{CasaCase::NON_TRANSITION_AGE_YOUTH_ICON}"
    end

    context "when a supervisor has volunteers who have and have not submitted a case contact in 14 days" do
      it "shows positive and negative numbers" do
        supervisor = create(:supervisor)
        enable_pundit(view, supervisor)
        create(:volunteer, :with_cases_and_contacts, supervisor: supervisor)
        create(:volunteer, :with_casa_cases, supervisor: supervisor)

        assign :supervisors, [supervisor]
        assign :casa_cases, []
        assign :available_volunteers, []

        sign_in supervisor
        render template: "supervisors/index"

        parsed_html = Nokogiri.HTML5(rendered)

        expect(parsed_html.css("#supervisors .success-bg").length).to eq(1)
        expect(parsed_html.css("#supervisors .danger-bg").length).to eq(1)
      end

      it "accurately displays the number of active and inactive volunteers per supervisor" do
        user = create(:casa_admin)
        enable_pundit(view, user)
        supervisor = create(:supervisor)
        create_list(:volunteer, 2, :with_cases_and_contacts, supervisor: supervisor)
        create(:volunteer, :with_casa_cases, supervisor: supervisor)
        casa_cases = create_list(:casa_case, 2, court_dates: [])

        assign :supervisors, [supervisor]
        assign :casa_cases, casa_cases
        assign :available_volunteers, []

        sign_in user
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
      it "omits the attempted contact stat bar" do
        user = create(:casa_admin)
        enable_pundit(view, user)
        supervisor = create(:supervisor)
        create(:volunteer, :with_casa_cases, supervisor: supervisor)
        casa_cases = create_list(:casa_case, 2, court_dates: [])

        assign :supervisors, [supervisor]
        assign :casa_cases, casa_cases
        assign :available_volunteers, []

        sign_in user
        render template: "supervisors/index"

        parsed_html = Nokogiri.HTML5(rendered)

        expect(parsed_html.css("#supervisors .success-bg").length).to eq(0)
        expect(parsed_html.css("#supervisors .danger-bg").length).to eq(1)
      end
    end

    context "when a supervisor only has volunteers who have submitted a case contact in 14 days" do
      it "shows the end of the attempted contact bar instead of the no attempted contact bar" do
        user = create(:casa_admin)
        enable_pundit(view, user)
        supervisor = create(:supervisor)
        create(:volunteer, :with_cases_and_contacts, supervisor: supervisor)
        casa_cases = create_list(:casa_case, 2, court_dates: [])

        assign :supervisors, [supervisor]
        assign :casa_cases, casa_cases
        assign :available_volunteers, []

        sign_in user
        render template: "supervisors/index"

        parsed_html = Nokogiri.HTML5(rendered)

        expect(parsed_html.css("#supervisors .success-bg").length).to eq(1)
        expect(parsed_html.css("#supervisors .danger-bg").length).to eq(0)
      end
    end

    context "when a supervisor does not have volunteers" do
      it "shows a no assigned volunteers message instead of attempted and no attempted contact bars" do
        user = create(:casa_admin)
        enable_pundit(view, user)
        supervisor = create(:supervisor)
        casa_cases = create_list(:casa_case, 2, court_dates: [])

        assign :supervisors, [supervisor]
        assign :casa_cases, casa_cases
        assign :available_volunteers, []

        sign_in user
        render template: "supervisors/index"

        parsed_html = Nokogiri.HTML5(rendered)

        expect(parsed_html.css("#supervisors .success-bg").length).to eq(0)
        expect(parsed_html.css("#supervisors .danger-bg").length).to eq(0)
        expect(parsed_html.css("#supervisors .bg-secondary").length).to eq(1)
      end
    end
  end

  context "when logged in as a supervisor" do
    it "cannot access the 'New Supervisor' button" do
      user = create(:supervisor)
      enable_pundit(view, user)
      casa_cases = create_list(:casa_case, 2, court_dates: [])

      assign :casa_cases, casa_cases
      assign :supervisors, []
      assign :available_volunteers, []

      sign_in user
      render template: "supervisors/index"

      expect(rendered).to_not have_link("New Supervisor", href: new_supervisor_path)
    end
  end
end
