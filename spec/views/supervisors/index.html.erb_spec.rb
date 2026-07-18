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

    it "shows the casa_cases-without-court-dates list" do
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

      cases = Nokogiri.HTML5(rendered).at_css("[data-test='cases-without-court-dates']")
      expect(cases.text).to include("123")
      expect(cases.text).to include("Active")
      expect(cases.text).to include("456")
      expect(cases.text).to include("Inactive")

      # Transition-aged youth renders as a pill/label, never the decorative emoji (design.md).
      expect(rendered).not_to include(CasaCase::TRANSITION_AGE_YOUTH_ICON)
      expect(rendered).not_to include(CasaCase::NON_TRANSITION_AGE_YOUTH_ICON)
      expect(cases.css(".bg-violet-50")).not_to be_empty
    end

    context "when a supervisor has volunteers who have and have not submitted a case contact in 14 days" do
      it "shows the attempting and not-attempting stats" do
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

        expect(parsed_html.css("#supervisors [data-stat='attempting']").length).to eq(1)
        expect(parsed_html.css("#supervisors [data-stat='not-attempting']").length).to eq(1)
      end

      it "accurately displays the number of attempting and not-attempting volunteers per supervisor" do
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

        expect(parsed_html.css("#supervisors [data-stat='attempting']").text.to_i).to eq(2)
        expect(parsed_html.css("#supervisors [data-stat='not-attempting']").text.to_i).to eq(1)
      end
    end

    context "when a supervisor only has volunteers who have not submitted a case contact in 14 days" do
      it "omits the attempting stat" do
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

        expect(parsed_html.css("#supervisors [data-stat='attempting']").length).to eq(0)
        expect(parsed_html.css("#supervisors [data-stat='not-attempting']").length).to eq(1)
      end
    end

    context "when a supervisor only has volunteers who have submitted a case contact in 14 days" do
      it "omits the not-attempting stat" do
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

        expect(parsed_html.css("#supervisors [data-stat='attempting']").length).to eq(1)
        expect(parsed_html.css("#supervisors [data-stat='not-attempting']").length).to eq(0)
      end
    end

    context "when a supervisor does not have volunteers" do
      it "shows a no-assigned-volunteers message instead of the contact stats" do
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

        expect(parsed_html.css("#supervisors [data-stat='attempting']").length).to eq(0)
        expect(parsed_html.css("#supervisors [data-stat='not-attempting']").length).to eq(0)
        expect(parsed_html.css("#supervisors [data-stat='no-volunteers']").length).to eq(1)
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

      expect(rendered).not_to have_link("New Supervisor", href: new_supervisor_path)
    end
  end
end
