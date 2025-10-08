require "rails_helper"

VOLUNTEER_SELECT_ID = "multiple-select-field2"
SUPERVISOR_SELECT_ID = "multiple-select-field1"
CONTACT_TYPE_SELECT_ID = "multiple-select-field3"
CONTACT_TYPE_GROUP_SELECT_ID = "multiple-select-field4"

RSpec.describe "reports", :js, type: :system do
  shared_examples "downloads report button" do |button_name, feedback|
    it "downloads #{button_name.downcase}", :aggregate_failures do
      expect(page).to have_button(button_name)
      click_on button_name
      expect(page).to have_text(feedback)
    end
  end

  shared_examples "downloads case contacts report with filter" do |filter_name, setup_action, filter_action|
    it "downloads case contacts report with #{filter_name}" do
      instance_exec(&setup_action) if setup_action
      visit reports_path
      instance_exec(&filter_action)
      click_on "Download Report"
      expect(page).to have_text("Downloading Report")
    end
  end

  shared_examples "empty select downloads report" do |select_id, description|
    it "renders the #{description} select with no options and downloads the report" do
      expect(page).to have_select(select_id, options: [])
      click_on "Download Report"
      expect(page).to have_text("Downloading Report")
    end
  end

  context "with a volunteer user" do
    before do
      user = create(:volunteer)

      sign_in user
      visit reports_path
    end

    it "redirects to root", :aggregate_failures do
      expect(page).not_to have_text "Case Contacts Report"
      expect(page).to have_text "Sorry, you are not authorized to perform this action."
    end
  end

  %i[supervisor casa_admin].each do |role|
    # rubocop:disable RSpec/MultipleMemoizedHelpers
    context "with a #{role} user" do
      let(:user) { create(role) }
      let(:volunteer_name) { Faker::Name.unique.name }
      let(:supervisor_name) { Faker::Name.unique.name }
      let(:contact_type_name) { Faker::Lorem.unique.word }
      let(:contact_type_group_name) { Faker::Lorem.unique.word }
      let(:filter_start_date) { "2025-01-01" }
      let(:filter_end_date) { "2025-10-08" }

      before do
        sign_in user
        visit reports_path
      end

      it "renders form elements", :aggregate_failures do
        expect(page).to have_text "Case Contacts Report"
        expect(page).to have_field("report_start_date", with: 6.months.ago.strftime("%Y-%m-%d"))
        expect(page).to have_field("report_end_date", with: Date.today)
        expect(page).to have_text "Assigned To"
        expect(page).to have_text "Volunteers"
        expect(page).to have_text "Contact Type"
        expect(page).to have_text "Contact Type Group"
        expect(page).to have_text "Want Driving Reimbursement"
        expect(page).to have_text "Contact Made"
        expect(page).to have_text "Transition Aged Youth"
        expect(page).to have_field("Both", count: 3)
        expect(page).to have_field("Yes", count: 3)
        expect(page).to have_field("No", count: 3)
      end

      it "downloads case contacts report with default filters" do
        click_on "Download Report"
        expect(page).to have_text("Downloading Report")
      end

      include_examples "downloads report button", "Mileage Report", "Downloading Mileage Report"
      include_examples "downloads report button", "Missing Data Report", "Downloading Missing Data Report"
      include_examples "downloads report button", "Learning Hours Report", "Downloading Learning Hours Report"
      include_examples "downloads report button", "Export Volunteers Emails", "Downloading Export Volunteers Emails"
      include_examples "downloads report button", "Followups Report", "Downloading Followups Report"
      include_examples "downloads report button", "Placements Report", "Downloading Placements Report"

      shared_examples "case contacts report with filter" do |filter_type|
        it "downloads case contacts report with #{filter_type}" do
          click_on "Download Report"
          expect(page).to have_text("Downloading Report")
        end
      end

      context "with an assigned supervisor filter" do
        before do
          create(:supervisor, casa_org: user.casa_org, display_name: supervisor_name)
          visit reports_path
          select_report_filter_option(SUPERVISOR_SELECT_ID, supervisor_name)
        end

        include_examples "case contacts report with filter", "assigned supervisor"
      end

      context "with a volunteer filter" do
        before do
          create(:volunteer, casa_org: user.casa_org, display_name: volunteer_name)
          visit reports_path
          select_report_filter_option(VOLUNTEER_SELECT_ID, volunteer_name)
        end

        include_examples "case contacts report with filter", "volunteer"
      end

      context "with a contact type filter" do
        before do
          create(:contact_type, casa_org: user.casa_org, name: contact_type_name)
          visit reports_path
          select_report_filter_option(CONTACT_TYPE_SELECT_ID, contact_type_name)
        end

        include_examples "case contacts report with filter", "contact type"
      end

      context "with a contact type group filter" do
        before do
          create(:contact_type_group, casa_org: user.casa_org, name: contact_type_group_name)
          visit reports_path
          select_report_filter_option(CONTACT_TYPE_GROUP_SELECT_ID, contact_type_group_name)
        end

        include_examples "case contacts report with filter", "contact type group"
      end

      context "with a driving reimbursement filter" do
        before do
          visit reports_path
          choose_report_radio_option("want_driving_reimbursement", "true")
        end

        include_examples "case contacts report with filter", "driving reimbursement"
      end

      context "with a contact made filters" do
        before do
          visit reports_path
          choose_report_radio_option("contact_made", "true")
        end

        include_examples "case contacts report with filter", "contact made"
      end

      context "with a transition aged youth filter" do
        before do
          visit reports_path
          choose_report_radio_option("has_transitioned", "true")
        end

        include_examples "case contacts report with filter", "transition aged youth"
      end

      context "with a date range filter" do
        before do
          visit reports_path
          set_report_date_range(start_date: filter_start_date, end_date: filter_end_date)
        end

        include_examples "case contacts report with filter", "date range"
      end

      context "with multiple filters" do
        before do
          create(:volunteer, casa_org: user.casa_org, display_name: volunteer_name)
          create(:contact_type, casa_org: user.casa_org, name: contact_type_name)
          visit reports_path
          set_report_date_range(start_date: filter_start_date, end_date: filter_end_date)
          select_report_filter_option(VOLUNTEER_SELECT_ID, volunteer_name)
          select_report_filter_option(CONTACT_TYPE_SELECT_ID, contact_type_name)
          choose_report_radio_option("want_driving_reimbursement", "false")
        end

        include_examples "case contacts report with filter", "multiple filters"
      end

      context "with no volunteers in the org" do
        include_examples "empty select downloads report", VOLUNTEER_SELECT_ID, "volunteers"
      end

      context "with no contact type groups in the org" do
        include_examples "empty select downloads report", CONTACT_TYPE_GROUP_SELECT_ID, "contact type groups"
      end

      context "with no contact types in the org" do
        include_examples "empty select downloads report", CONTACT_TYPE_SELECT_ID, "contact types"
      end
    end
    # rubocop:enable RSpec/MultipleMemoizedHelpers
  end

  private

  def select_report_filter_option(select_id, option)
    expect(page).to have_select(select_id, with_options: [option])
    find("##{select_id}").select(option)
  end

  def set_report_date_range(start_date:, end_date:)
    fill_in "report_start_date", with: start_date
    fill_in "report_end_date", with: end_date
  end

  def choose_report_radio_option(field_name, value)
    find("input[name=\"report[#{field_name}]\"][value=\"#{value}\"]", visible: :all).click
  end
end
