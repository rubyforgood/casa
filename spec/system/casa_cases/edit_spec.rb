require "rails_helper"
require "stringio"

RSpec.describe "Edit CASA Case", type: :system do
  context "logged in as admin" do
    let(:organization) { build(:casa_org) }
    let(:admin) { create(:casa_admin, casa_org: organization) }
    let(:casa_case) { create(:casa_case, :with_judge, :with_one_court_order, casa_org: organization) }
    let(:contact_type_group) { create(:contact_type_group, casa_org: organization) }
    let!(:contact_type) { create(:contact_type, contact_type_group: contact_type_group) }

    before { sign_in admin }

    it_behaves_like "shows court dates links"

    it "shows court orders" do
      visit edit_casa_case_path(casa_case)

      court_order = casa_case.case_court_orders.first

      expect(page).to have_text(court_order.text)
      expect(page).to have_text(court_order.implementation_status.humanize)
    end

    it "edits case", js: true do
      visit casa_case_path(casa_case.id)
      click_on "Edit Case Details"
      expect(page).to have_select("Hearing type")
      expect(page).to have_select("Judge")
      select "Submitted", from: "casa_case_court_report_status"
      check contact_type.name

      page.find("#add-mandate-button").click
      find("#court-orders-list-container").first("textarea").send_keys("Court Mandate Text One")

      within ".top-page-actions" do
        click_on "Update CASA Case"
      end
      expect(page).to have_text("Submitted")
      expect(page).to have_text("Court Date")
      expect(page).to have_text("Court Report Due Date")
      expect(page).to have_field("Court Report Due Date")
      expect(page).to have_text("Court Mandate Text One")
      expect(page).not_to have_text("Deactivate Case")

      expect(casa_case.contact_types).to eq [contact_type]
      has_checked_field? contact_type.name
    end

    it "deactivates a case", js: true do
      visit edit_casa_case_path(casa_case)

      click_on "Deactivate CASA Case"
      click_on "Yes, deactivate"
      expect(page).to have_text("Case #{casa_case.case_number} has been deactivated")
      expect(page).to have_text("Case was deactivated on: #{I18n.l(casa_case.updated_at, format: :standard, default: nil)}")
      expect(page).to have_text("Reactivate CASA Case")
      expect(page).to_not have_text("Court Date")
      expect(page).to_not have_text("Court Report Due Date")
      expect(page).to_not have_field("Court Report Due Date")
    end

    it "reactivates a case", js: true do
      visit edit_casa_case_path(casa_case)
      click_on "Deactivate CASA Case"
      click_on "Yes, deactivate"
      click_on "Reactivate CASA Case"

      expect(page).to have_text("Case #{casa_case.case_number} has been reactivated.")
      expect(page).to have_text("Deactivate CASA Case")
      expect(page).to have_text("Court Date")
      expect(page).to have_text("Court Report Due Date")
      expect(page).to have_field("Court Report Due Date")
    end
  end

  context "logged in as supervisor" do
    let(:casa_org) { build(:casa_org) }
    let(:supervisor) { create(:supervisor, casa_org: casa_org) }
    let(:casa_case) { create(:casa_case, :with_judge, :with_hearing_type, :with_one_court_order, casa_org: casa_org) }
    let!(:contact_type_group) { build(:contact_type_group, casa_org: casa_org) }
    let!(:contact_type_1) { create(:contact_type, name: "Youth", contact_type_group: contact_type_group) }
    let!(:contact_type_2) { build(:contact_type, name: "Supervisor", contact_type_group: contact_type_group) }
    let!(:next_year) { (Date.today.year + 1).to_s }

    before { sign_in supervisor }

    it_behaves_like "shows court dates links"

    it "edits case", js: true do
      visit casa_case_path(casa_case)
      expect(page).to have_text("Court Report Status: Not submitted")
      visit edit_casa_case_path(casa_case)
      select "Submitted", from: "casa_case_court_report_status"
      check "Youth"

      fill_in "Court Report Due Date", with: Date.new(next_year.to_i, 9, 8).strftime("%Y/%m/%d\n")

      page.find("#add-mandate-button").click
      find("#court-orders-list-container").first("textarea").send_keys("Court Mandate Text One")

      select "Partially implemented", from: "casa_case[case_court_orders_attributes][0][implementation_status]"

      expect(page).to have_text("Set Implementation Status")

      within ".actions" do
        click_on "Update CASA Case"
      end
      has_checked_field? "Youth"
      has_no_checked_field? "Supervisor"

      expect(page).to have_text("Court Date")
      expect(page).to have_text("Court Report Due Date")
      expect(page).to have_field("Court Report Due Date")
      expect(page).to have_field("Court Report Due Date", with: "#{next_year}-09-08")
      expect(page).to have_text("Court Mandate Text One")
      expect(page).to have_text("Partially implemented")

      visit casa_case_path(casa_case)

      expect(page).to have_text("Court Report Status: Submitted")
      expect(page).to have_text("8-SEP-#{next_year}")
    end

    context "with an available judge" do
      let!(:judge) { create(:judge, casa_org: casa_org) }

      it "is able to assign a judge to the case when there is no assigned judge", js: true do
        casa_case.update(judge: nil)

        visit edit_casa_case_path(casa_case)

        expect(page).to have_select("Judge", selected: "-Select Judge-")
        select judge.name, from: "casa_case_judge_id"

        within ".actions" do
          click_on "Update CASA Case"
        end

        expect(page).to have_select("Judge", selected: judge.name)
        expect(casa_case.reload.judge).to eq judge
      end

      it "is able to assign another judge to the case", js: true do
        visit edit_casa_case_path(casa_case)

        expect(page).to have_select("Judge", selected: casa_case.judge.name)
        select judge.name, from: "casa_case_judge_id"

        within ".actions" do
          click_on "Update CASA Case"
        end

        expect(page).to have_select("Judge", selected: judge.name)
        expect(casa_case.reload.judge).to eq judge
      end

      it "is able to unassign a judge from the case", js: true do
        visit edit_casa_case_path(casa_case)

        expect(page).to have_select("Judge", selected: casa_case.judge.name)
        select "-Select Judge-", from: "casa_case_judge_id"

        within ".actions" do
          click_on "Update CASA Case"
        end

        expect(page).to have_select("Judge", selected: "-Select Judge-")
        expect(casa_case.reload.judge).to be_nil
      end
    end

    it "views deactivated case" do
      casa_case.deactivate
      visit edit_casa_case_path(casa_case)

      expect(page).to have_text("Case was deactivated on: #{I18n.l(casa_case.updated_at, format: :standard, default: nil)}")
      expect(page).not_to have_text("Court Date")
      expect(page).not_to have_text("Court Report Due Date")
      expect(page).not_to have_text("Day")
      expect(page).not_to have_text("Month")
      expect(page).not_to have_text("Year")
      expect(page).not_to have_text("Reactivate Case")
      expect(page).not_to have_text("Update Casa Case")
    end

    it "shows court orders" do
      visit edit_casa_case_path(casa_case)

      court_order = casa_case.case_court_orders.first

      expect(page).to have_text(court_order.text)
      expect(page).to have_text(court_order.implementation_status.humanize)
    end

    context "When a Casa instance has no judge names added" do
      it "does not display judge names details" do
        casa_case = create(:casa_case, casa_org: casa_org, judge: nil)

        visit edit_casa_case_path(casa_case)

        expect(page).not_to have_select("Judge")
      end
    end

    context "When an admin has added judge names to a Casa instance" do
      it "displays judge details as select option" do
        create :judge, casa_org: casa_org

        visit edit_casa_case_path(casa_case)

        expect(page).to have_select("Judge")
      end
    end

    describe "assign and unassign a volunteer to a case" do
      let(:organization) { build(:casa_org) }
      let(:casa_case) { create(:casa_case, casa_org: organization) }
      let(:supervisor1) { build(:supervisor, casa_org: organization) }
      let!(:volunteer) { create(:volunteer, supervisor: supervisor1, casa_org: organization) }

      def sign_in_and_assign_volunteer
        sign_in supervisor1
        visit casa_case_path(casa_case.id)
        click_on "Edit Case Details"

        select volunteer.display_name, from: "case_assignment[volunteer_id]"

        click_on "Assign Volunteer"
      end

      before do
        travel_to Time.zone.local(2020, 8, 29, 4, 5, 6)
      end

      after { travel_back }

      context "when a volunteer is assigned to a case" do
        it "marks the volunteer as assigned and shows the start date of the assignment", js: true do
          sign_in_and_assign_volunteer
          expect(casa_case.case_assignments.count).to eq 1

          unassign_button = page.find("button.btn-outline-danger")
          expect(unassign_button.text).to eq "Unassign Volunteer"

          assign_badge = page.find("span.badge-success")
          expect(assign_badge.text).to eq "ASSIGNED"
        end

        it "shows an assignment start date and no assignment end date" do
          sign_in_and_assign_volunteer
          assignment_start = page.find("td[data-test=assignment-start]").text
          assignment_end = page.find("td[data-test=assignment-end]").text

          expect(assignment_start).to eq("August 29, 2020")
          expect(assignment_end).to be_empty
        end
      end

      context "when a volunteer is unassigned from a case" do
        it "marks the volunteer as unassigned and shows assignment start/end dates", js: true do
          sign_in_and_assign_volunteer
          unassign_button = page.find("button.btn-outline-danger")
          expect(unassign_button.text).to eq "Unassign Volunteer"

          click_on "Unassign Volunteer"

          assign_badge = page.find("span.badge-danger")
          expect(assign_badge.text).to eq "UNASSIGNED"

          expected_start_and_end_date = "August 29, 2020"

          assignment_start = page.find("td[data-test=assignment-start]").text
          assignment_end = page.find("td[data-test=assignment-end]").text

          expect(assignment_start).to eq(expected_start_and_end_date)
          expect(assignment_end).to eq(expected_start_and_end_date)
        end
      end

      context "when supervisor other than volunteer's supervisor" do
        before { volunteer.update(supervisor: build(:supervisor)) }

        it "unassigns volunteer", js: true do
          sign_in_and_assign_volunteer
          unassign_button = page.find("button.btn-outline-danger")
          expect(unassign_button.text).to eq "Unassign Volunteer"

          click_on "Unassign Volunteer"

          assign_badge = page.find("span.badge-danger")
          expect(assign_badge.text).to eq "UNASSIGNED"
        end
      end

      it "when can assign only active volunteer to a case" do
        create(:volunteer, casa_org: organization)
        build_stubbed(:volunteer, :inactive, casa_org: organization)

        sign_in_and_assign_volunteer

        expect(find("select[name='case_assignment[volunteer_id]']").all("option").count).to eq 1
      end
    end

    describe "case assigned to multiple volunteers" do
      let(:organization) { build(:casa_org) }
      let(:supervisor) { create(:casa_admin, casa_org: organization) }
      let(:casa_case) { create(:casa_case, casa_org: organization) }

      let!(:volunteer_1) { create(:volunteer, display_name: "AAA", casa_org: organization) }
      let!(:volunteer_2) { create(:volunteer, display_name: "BBB", casa_org: organization) }

      it "supervisor assigns multiple volunteers to the same case" do
        sign_in supervisor
        visit edit_casa_case_path(casa_case.id)

        select volunteer_1.display_name, from: "Select a Volunteer"
        click_on "Assign Volunteer"
        expect(page).to have_text("Volunteer assigned to case")
        expect(page).to have_text(volunteer_1.display_name)

        select volunteer_2.display_name, from: "Select a Volunteer"
        click_on "Assign Volunteer"
        expect(page).to have_text("Volunteer assigned to case")
        expect(page).to have_text(volunteer_2.display_name)
      end
    end

    context "deleting court orders", js: true do
      let(:casa_case) { create(:casa_case, :with_one_court_order) }
      let(:text) { casa_case.case_court_orders.first.text }

      it "can delete a court order" do
        visit edit_casa_case_path(casa_case.id)

        expect(page).to have_text(text)

        find("button.remove-mandate-button").click
        expect(page).to have_text("Are you sure you want to remove this court order? Doing so will delete all records \
of it unless it was included in a previous court report.")

        find("button.swal2-confirm").click
        expect(page).to have_text("Court order has been removed.")
        click_on "OK"
        expect(page).to_not have_text(text)

        within ".actions" do
          click_on "Update CASA Case"
        end
        expect(page).to_not have_text(text)
      end
    end

    context "with an available hearing type", js: true do
      let!(:hearing_type) { create(:hearing_type, casa_org: casa_org) }

      it "is able to assign a hearing type when there is none assigned" do
        casa_case.update(hearing_type: nil)

        visit edit_casa_case_path(casa_case.id)

        expect(page).to have_select("Hearing type",
          selected: I18n.t("casa_cases.form.prompt.select_hearing_type"))
        select hearing_type.name, from: "casa_case_hearing_type_id"

        within ".actions" do
          click_on "Update CASA Case"
        end

        expect(page).to have_select("Hearing type", selected: hearing_type.name)
        expect(casa_case.reload.hearing_type).to eq hearing_type
      end

      it "is able to assign another hearing type to the case" do
        visit edit_casa_case_path(casa_case.id)

        expect(page).to have_select("Hearing type", selected: casa_case.hearing_type.name)
        select hearing_type.name, from: "casa_case_hearing_type_id"

        within ".actions" do
          click_on "Update CASA Case"
        end

        expect(page).to have_select("Hearing type", selected: hearing_type.name)
        expect(casa_case.reload.hearing_type).to eq hearing_type
      end

      it "is able to unassign a hearing type from the case" do
        expect(casa_case.hearing_type).not_to be_nil

        visit edit_casa_case_path(casa_case.id)

        expect(page).to have_select("Hearing type",
          selected: casa_case.hearing_type.name)
        select(I18n.t("casa_cases.form.prompt.select_hearing_type"),
          from: "casa_case_hearing_type_id")

        within ".actions" do
          click_on "Update CASA Case"
        end

        expect(page).to have_select("Hearing type",
          selected: I18n.t("casa_cases.form.prompt.select_hearing_type"))
        expect(casa_case.reload.hearing_type).to be_nil
      end
    end
  end

  context "logged in as volunteer" do
    let(:volunteer) { build(:volunteer) }
    let(:casa_case) { create(:casa_case, :with_one_court_order, casa_org: volunteer.casa_org) }
    let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }

    let!(:court_dates) do
      [10, 30, 31, 90].map { |n| create(:court_date, casa_case: casa_case, date: n.days.ago) }
    end

    let!(:reports) do
      [5, 11, 23, 44, 91].map do |n|
        report = CaseCourtReport.new(
          volunteer_id: volunteer.id,
          case_id: casa_case.id,
          path_to_template: "app/documents/templates/default_report_template.docx"
        )
        casa_case.court_reports.attach(io: StringIO.new(report.generate_to_string), filename: "report#{n}.docx")
        attached_report = casa_case.latest_court_report
        attached_report.created_at = n.days.ago
        attached_report.save!
        attached_report
      end
    end

    before { sign_in volunteer }

    it_behaves_like "shows court dates links"

    it "views attached court reports" do
      visit edit_casa_case_path(casa_case)

      # test court dates with reports get the correct ones
      [[0, 1], [2, 3], [3, 4]].each do |di, ri|
        expect(page).to have_link("(Attached Report)", href: rails_blob_path(reports[ri], disposition: "attachment"))
        expect(page).to have_link(I18n.l(court_dates[di].date, format: :full, default: nil))
      end

      # and that the one with no report still gets one
      expect(page).to have_link(I18n.l(court_dates[1].date, format: :full, default: nil))
      expect(page).to have_text(I18n.l(court_dates[1].date, format: :full, default: nil))
    end

    it "shows court orders" do
      visit edit_casa_case_path(casa_case)

      court_order = casa_case.case_court_orders.first

      expect(page).to have_text(court_order.text)
      expect(page).to have_text(court_order.implementation_status.humanize)
    end

    it "edits case" do
      visit casa_case_path(casa_case)
      expect(page).to have_text("Court Report Status: Not submitted")
      visit edit_casa_case_path(casa_case)
      select "Submitted", from: "casa_case_court_report_status"
      within ".actions" do
        click_on "Update CASA Case"
      end

      expect(page).to have_field("Court Report Due Date")
      expect(page).not_to have_text("Deactivate Case")

      expect(page).to have_css("#add-mandate-button")

      visit casa_case_path(casa_case)
      expect(page).to have_text("Court Report Status: Submitted")
    end
  end
end
