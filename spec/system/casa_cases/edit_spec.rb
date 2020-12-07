require "rails_helper"

RSpec.describe "casa_cases/edit", type: :system do
  context "when admin" do
    let(:organization) { create(:casa_org) }
    let(:admin) { create(:casa_admin, casa_org: organization) }
    let(:casa_case) { create(:casa_case, casa_org: organization) }
    let!(:judge) { create(:judge, casa_org: organization) }
    let(:contact_type_group) { create(:contact_type_group, casa_org: organization) }
    let!(:school) { create(:contact_type, name: "School", contact_type_group: contact_type_group) }
    let!(:therapist) { create(:contact_type, name: "Therapist", contact_type_group: contact_type_group) }

    before { sign_in admin }

    it "clicks back button after editing case" do
      visit edit_casa_case_path(casa_case)
      select "Submitted", from: "casa_case_court_report_status"
      click_on "Back"
      visit edit_casa_case_path(casa_case)
      expect(casa_case).not_to be_court_report_submitted
    end

    it "edits case" do
      visit casa_case_path(casa_case.id)
      click_on "Edit Case Details"
      expect(page).to have_select("Hearing type")
      expect(page).to have_select("Judge")
      select "Submitted", from: "casa_case_court_report_status"
      click_on "Update CASA Case"
      expect(page).to have_text("Submitted")
      expect(page).to have_text("Court Date")
      expect(page).to have_text("Court Report Due Date")
      expect(page).to have_text("Day")
      expect(page).to have_text("Month")
      expect(page).to have_text("Year")
      expect(page).not_to have_text("Deactivate Case")
    end

    it "deactivates a case" do
      visit edit_casa_case_path(casa_case)

      click_on "Deactivate CASA Case"
      sleep 10
      click_on "Yes, deactivate"
      expect(page).to have_text("Case #{casa_case.case_number} has been deactivated")
      expect(page).to have_text("Case was deactivated on: #{casa_case.updated_at.strftime(DateFormat::MM_DD_YYYY)}")
      expect(page).to have_text("Reactivate CASA Case")
      expect(page).to_not have_text("Court Date")
      expect(page).to_not have_text("Court Report Due Date")
      expect(page).to_not have_text("Day")
      expect(page).to_not have_text("Month")
      expect(page).to_not have_text("Year")
    end

    it "reactivates a case" do
      visit edit_casa_case_path(casa_case)
      click_on "Deactivate CASA Case"
      sleep 10
      click_on "Yes, deactivate"
      click_on "Reactivate CASA Case"

      expect(page).to have_text("Case #{casa_case.case_number} has been reactivated.")
      expect(page).to have_text("Deactivate CASA Case")
      expect(page).to have_text("Court Date")
      expect(page).to have_text("Court Report Due Date")
      expect(page).to have_text("Day")
      expect(page).to have_text("Month")
      expect(page).to have_text("Year")
    end
  end

  context "when supervisor" do
    let(:casa_org) { create(:casa_org) }
    let(:supervisor) { create(:supervisor, casa_org: casa_org) }
    let(:casa_case) { create(:casa_case, casa_org: casa_org) }
    let!(:contact_type_group) { create(:contact_type_group, casa_org: casa_org) }
    let!(:contact_type_1) { create(:contact_type, name: "Youth", contact_type_group: contact_type_group) }
    let!(:contact_type_2) { create(:contact_type, name: "Supervisor", contact_type_group: contact_type_group) }
    let!(:next_year) { (Date.today.year + 1).to_s }

    before do
      sign_in supervisor
    end

    it "edits case" do
      visit casa_case_path(casa_case)
      expect(page).to have_text("Court Report Status: Not submitted")
      visit edit_casa_case_path(casa_case)
      select "Submitted", from: "casa_case_court_report_status"
      check "Youth"
      select "4", from: "casa_case_court_date_3i"
      select "November", from: "casa_case_court_date_2i"
      select next_year, from: "casa_case_court_date_1i"

      select "8", from: "casa_case_court_report_due_date_3i"
      select "September", from: "casa_case_court_report_due_date_2i"
      select next_year, from: "casa_case_court_report_due_date_1i"

      click_on "Update CASA Case"
      has_checked_field? "Youth"
      has_no_checked_field? "Supervisor"

      expect(page).to have_text("Court Date")
      expect(page).to have_text("Court Report Due Date")
      expect(page).to have_text("Day")
      expect(page).to have_text("Month")
      expect(page).to have_text("Year")
      expect(page).to have_text("November")
      expect(page).to have_text("September")

      visit casa_case_path(casa_case)

      expect(page).to have_text("Court Report Status: Submitted")
      expect(page).to have_text("4-NOV-#{next_year}")
      expect(page).to have_text("8-SEP-#{next_year}")
    end

    it "will return error message if date fields are not fully selected" do
      visit casa_case_path(casa_case)
      expect(page).to have_text("Court Report Status: Not submitted")
      visit edit_casa_case_path(casa_case)

      select "November", from: "casa_case_court_date_2i"
      select "April", from: "casa_case_court_report_due_date_2i"

      click_on "Update CASA Case"

      expect(page).to have_text("Court date was not a valid date.")
      expect(page).to have_text("Court report due date was not a valid date.")
    end

    it "will return error message if date fields are not valid" do
      visit casa_case_path(casa_case)
      expect(page).to have_text("Court Report Status: Not submitted")
      visit edit_casa_case_path(casa_case)

      select "31", from: "casa_case_court_date_3i"
      select "April", from: "casa_case_court_date_2i"
      select next_year, from: "casa_case_court_date_1i"

      select "31", from: "casa_case_court_report_due_date_3i"
      select "April", from: "casa_case_court_report_due_date_2i"
      select next_year, from: "casa_case_court_report_due_date_1i"

      click_on "Update CASA Case"

      expect(page).to have_text("Court date was not a valid date.")
      expect(page).to have_text("Court report due date was not a valid date.")
    end

    it "views deactivated case" do
      casa_case.deactivate
      visit edit_casa_case_path(casa_case)

      expect(page).to have_text("Case was deactivated on: #{casa_case.updated_at.strftime(DateFormat::MM_DD_YYYY)}")
      expect(page).not_to have_text("Court Date")
      expect(page).not_to have_text("Court Report Due Date")
      expect(page).not_to have_text("Day")
      expect(page).not_to have_text("Month")
      expect(page).not_to have_text("Year")
      expect(page).not_to have_text("Reactivate Case")
      expect(page).not_to have_text("Update Casa Case")
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
      let(:organization) { create(:casa_org) }
      let(:casa_case) { create(:casa_case, casa_org: organization) }
      let(:supervisor1) { create(:supervisor, casa_org: organization) }
      let!(:volunteer) { create(:volunteer, supervisor: supervisor1, casa_org: organization) }

      before do
        travel_to Time.zone.local(2020, 8, 29, 4, 5, 6)
        sign_in supervisor1
        visit casa_case_path(casa_case.id)
        click_on "Edit Case Details"

        select volunteer.display_name, from: "case_assignment[volunteer_id]"

        click_on "Assign Volunteer"
      end

      after { travel_back }

      context "when a volunteer is assigned to a case" do
        it "marks the volunteer as assigned and shows the start date of the assignment" do
          expect(casa_case.case_assignments.count).to eq 1

          unassign_button = page.find("input.btn-outline-danger")
          expect(unassign_button.value).to eq "Unassign Volunteer"

          assign_badge = page.find("span.badge-success")
          expect(assign_badge.text).to eq "ASSIGNED"
        end

        it "shows an assignment start date and no assignment end date" do
          assignment_start = page.find("td[data-test=assignment-start]").text
          assignment_end = page.find("td[data-test=assignment-end]").text

          expect(assignment_start).to eq("August 29, 2020")
          expect(assignment_end).to be_empty
        end
      end

      context "when a volunteer is unassigned from a case" do
        it "marks the volunteer as unassigned and shows assignment start/end dates" do
          unassign_button = page.find("input.btn-outline-danger")
          expect(unassign_button.value).to eq "Unassign Volunteer"

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
        before { volunteer.update(supervisor: create(:supervisor)) }

        it "unassigns volunteer" do
          unassign_button = page.find("input.btn-outline-danger")
          expect(unassign_button.value).to eq "Unassign Volunteer"

          click_on "Unassign Volunteer"

          assign_badge = page.find("span.badge-danger")
          expect(assign_badge.text).to eq "UNASSIGNED"
        end
      end

      it "when can assign only active volunteer to a case" do
        create(:volunteer, casa_org: organization)
        create(:volunteer, :inactive, casa_org: organization)

        expect(find("select[name='case_assignment[volunteer_id]']").all("option").count).to eq 1
      end
    end

    describe "case assigned to multiple volunteers" do
      let(:organization) { create(:casa_org) }
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
  end

  context "when volunteer" do
    let(:volunteer) { create(:volunteer) }
    let(:casa_case) { create(:casa_case, casa_org: volunteer.casa_org) }
    let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }

    before { sign_in volunteer }

    it "clicks back button after editing case" do
      visit edit_casa_case_path(casa_case)

      expect(page).to_not have_select("Hearing type")
      expect(page).to_not have_select("Judge")

      select "Submitted", from: "casa_case_court_report_status"
      click_on "Update CASA Case"

      click_on "Back"

      expect(page).to have_text("My Case")
    end

    it "edits case" do
      visit casa_case_path(casa_case)
      expect(page).to have_text("Court Report Status: Not submitted")
      visit edit_casa_case_path(casa_case)
      select "Submitted", from: "casa_case_court_report_status"
      click_on "Update CASA Case"

      expect(page).to have_text("Court Date")
      expect(page).to have_text("Court Report Due Date")
      expect(page).not_to have_text("Day")
      expect(page).not_to have_text("Month")
      expect(page).not_to have_text("Year")
      expect(page).not_to have_text("Deactivate Case")

      visit casa_case_path(casa_case)
      expect(page).to have_text("Court Report Status: Submitted")
    end
  end
end
