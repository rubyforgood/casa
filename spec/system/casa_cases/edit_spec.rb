require "rails_helper"
require "stringio"

RSpec.describe "Edit CASA Case", type: :system do
  context "logged in as admin" do
    let(:organization) { build(:casa_org) }
    let(:other_organization) { build(:casa_org) }
    let(:admin) { create(:casa_admin, casa_org: organization) }
    let(:other_org_admin) { create(:casa_admin, casa_org: other_organization) }
    let(:casa_case) { create(:casa_case, :with_one_court_order, casa_org: organization) }
    let(:other_org_casa_case) { create(:casa_case, :with_one_court_order, casa_org: other_organization) }
    let(:contact_type_group) { create(:contact_type_group, casa_org: organization) }
    let(:other_org_contact_type_group) { create(:contact_type_group, casa_org: other_organization) }
    let!(:contact_type) { create(:contact_type, contact_type_group: contact_type_group) }
    let!(:other_org_contact_type) { create(:contact_type, contact_type_group: other_org_contact_type_group) }
    let!(:siblings_casa_cases) do
      create(:casa_case, :with_one_court_order, casa_org: organization)
      organization.casa_cases.excluding(casa_case)
    end
    let!(:other_org_siblings_casa_cases) do
      create(:casa_case, :with_one_court_order, casa_org: other_organization)
      other_organization.casa_cases.excluding(other_org_casa_case)
    end

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
      select "Submitted", from: "casa_case_court_report_status"
      check contact_type.name

      page.find('button[data-action="extended-nested-form#add"]').click
      find("#court-orders-list-container").first("textarea").send_keys("Court Order Text One")

      within ".top-page-actions" do
        click_on "Update CASA Case"
      end
      expect(page).to have_text("Submitted")
      expect(page).to have_text("Court Date")
      expect(page).not_to have_text("Court Report Due Date")
      expect(page).not_to have_field("Court Report Due Date")
      expect(page).to have_text("Youth's Date in Care")
      expect(page).to have_text("Court Order Text One")
      expect(page).not_to have_text("Deactivate Case")

      expect(casa_case.contact_types).to eq [contact_type]
      has_checked_field? contact_type.name
    end

    it "does not display anything when not part of the organization", js: true do
      visit casa_case_path(other_org_casa_case.id)
      expect(page).to have_text("Sorry, you are not authorized to perform this action.")
    end

    it "deactivates a case when part of the same organization", js: true do
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

    it "does not allow an admin to deactivate a case if not in an organization" do
      visit edit_casa_case_path(other_org_casa_case)
      expect(page).to have_text("Sorry, you are not authorized to perform this action.")
    end

    it "reactivates a case", js: true do
      visit edit_casa_case_path(casa_case)
      click_on "Deactivate CASA Case"
      click_on "Yes, deactivate"
      click_link("Reactivate CASA Case")

      expect(page).to have_text("Case #{casa_case.case_number} has been reactivated.")
      expect(page).to have_text("Deactivate CASA Case")
      expect(page).to have_text("Court Date")
      expect(page).not_to have_text("Court Report Due Date")
      expect(page).not_to have_field("Court Report Due Date")
    end

    context "when trying to assign a volunteer to a case" do
      it "should be able to assign volunteers if in the same organization", js: true do
        visit edit_casa_case_path(casa_case)

        expect(page).to have_content("Manage Volunteers")
        expect(page).to have_css("#volunteer-assignment")
      end

      it "should error if trying to assign volunteers for another organization" do
        visit edit_casa_case_path(other_org_casa_case)
        expect(page).to have_text("Sorry, you are not authorized to perform this action.")
      end
    end

    context "Copy all court orders from a case" do
      it "should not allow access to cases not within the organization" do
        visit edit_casa_case_path(other_org_casa_case)
        expect(page).to have_text("Sorry, you are not authorized to perform this action.")
      end

      it "copy button should be disabled when no case is selected", js: true do
        visit edit_casa_case_path(casa_case)
        expect(page).to have_button("copy-court-button", disabled: true)
      end

      it "copy button should be enabled when a case is selected", js: true do
        visit edit_casa_case_path(casa_case)
        select siblings_casa_cases.first.case_number, from: "casa_case_siblings_casa_cases"
        expect(page).to have_button("copy-court-button", disabled: false)
      end

      it "should contains all case from organization except current case", js: true do
        visit edit_casa_case_path(casa_case)
        within "#casa_case_siblings_casa_cases" do
          siblings_casa_cases.each do |scc|
            expect(page).to have_selector("option", text: scc.case_number)
          end
          expect(page).not_to have_selector("option", text: casa_case.case_number)
        end
      end

      it "should copy all court orders from selected case", js: true do
        visit casa_case_path(casa_case.id)
        click_on "Edit Case Details"
        selected_case = siblings_casa_cases.first
        select selected_case.case_number, from: "casa_case_siblings_casa_cases"
        click_on "Copy"
        within ".swal2-popup" do
          expect(page).to have_text("Copy all orders from case ##{selected_case.case_number}?")
          click_on "Copy"
        end
        expect(page).to have_text("Court orders have been copied")
        casa_case.reload
        court_orders_text = casa_case.case_court_orders.map(&:text)
        court_orders_status = casa_case.case_court_orders.map(&:implementation_status)
        selected_case.case_court_orders.each do |orders|
          expect(court_orders_text).to include orders.text
          expect(court_orders_status).to include orders.implementation_status
        end
      end

      it "should not overwrite existing court orders", js: true do
        visit casa_case_path(casa_case.id)
        click_on "Edit Case Details"
        selected_case = siblings_casa_cases.first
        current_orders = casa_case.case_court_orders.each(&:dup)
        select selected_case.case_number, from: "casa_case_siblings_casa_cases"
        click_on "Copy"
        within ".swal2-popup" do
          expect(page).to have_text("Copy all orders from case ##{selected_case.case_number}?")
          click_on "Copy"
        end
        expect(page).to have_text("Court orders have been copied")
        casa_case.reload
        current_orders.each do |orders|
          expect(casa_case.case_court_orders.map(&:text)).to include orders.text
        end
        expect(casa_case.case_court_orders.count).to be >= current_orders.count
      end

      it "should not move court orders from one case to another", js: true do
        visit casa_case_path(casa_case.id)
        click_on "Edit Case Details"
        selected_case = siblings_casa_cases.first
        select selected_case.case_number, from: "casa_case_siblings_casa_cases"
        click_on "Copy"
        within ".swal2-popup" do
          expect(page).to have_text("Copy all orders from case ##{selected_case.case_number}?")
          click_on "Copy"
        end
        expect(page).to have_text("Court orders have been copied")
        casa_case.reload
        expect(selected_case.case_court_orders.count).to be > 0
      end
    end
  end

  context "logged in as supervisor" do
    let(:casa_org) { build(:casa_org) }
    let(:supervisor) { create(:supervisor, casa_org: casa_org) }
    let(:casa_case) { create(:casa_case, :with_one_court_order, casa_org: casa_org) }
    let!(:contact_type_group) { build(:contact_type_group, casa_org: casa_org) }
    let!(:contact_type_1) { create(:contact_type, name: "Youth", contact_type_group: contact_type_group) }
    let!(:contact_type_2) { build(:contact_type, name: "Supervisor", contact_type_group: contact_type_group) }
    let!(:next_year) { (Date.today.year + 1).to_s }

    before { sign_in supervisor }

    it_behaves_like "shows court dates links"

    it "edits case", js: true do
      stub_twillio
      visit casa_case_path(casa_case)
      expect(page).to have_text("Court Report Status: Not submitted")
      visit edit_casa_case_path(casa_case)
      select "Submitted", from: "casa_case_court_report_status"
      check "Youth"

      # fill_in "Court Report Due Date", with: Date.new(next_year.to_i, 9, 8).strftime("%Y/%m/%d\n")

      page.find('button[data-action="extended-nested-form#add"]').click
      find("#court-orders-list-container").first("textarea").send_keys("Court Order Text One")

      select "Partially implemented", from: "casa_case[case_court_orders_attributes][0][implementation_status]"

      expect(page).to have_text("Set Implementation Status")

      within ".actions-cc" do
        click_on "Update CASA Case"
      end
      has_checked_field? "Youth"
      has_no_checked_field? "Supervisor"

      expect(page).to have_text("Court Date")
      expect(page).not_to have_text("Court Report Due Date")
      expect(page).not_to have_field("Court Report Due Date")
      expect(page).not_to have_field("Court Report Due Date", with: "#{next_year}-09-08")
      expect(page).to have_text("Youth's Date in Care")
      expect(page).to have_text("Court Order Text One")
      expect(page).to have_text("Partially implemented")

      visit casa_case_path(casa_case)

      expect(page).to have_text("Court Report Status: Submitted")
      expect(page).not_to have_text("8-SEP-#{next_year}")
    end

    it "views deactivated case" do
      casa_case.deactivate
      visit edit_casa_case_path(casa_case)

      expect(page).to have_text("Case was deactivated on: #{I18n.l(casa_case.updated_at, format: :standard, default: nil)}")
      expect(page).not_to have_text("Court Date")
      expect(page).not_to have_text("Court Report Due Date")
      expect(page).not_to have_text("Youth's Date in Care")
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
        visit edit_casa_case_path(casa_case.case_number.parameterize)

        expect(page).to have_text(text)

        find('button[data-action="click->extended-nested-form#remove"]').click
        expect(page).to have_text("Are you sure you want to remove this court order? Doing so will delete all records \
of it unless it was included in a previous court report.")

        find("button.swal2-confirm").click
        expect(page).to_not have_text(text)

        within ".actions-cc" do
          click_on "Update CASA Case"
        end
        expect(page).to_not have_text(text)
      end
    end

    it "has all boxes checked by default" do
      visit edit_casa_case_path(casa_case)
      expect(page).to have_text("Select All Contact Types")
      expect(all("input[type=checkbox][class~=case-contact-contact-type]")).not_to be_empty
      all("input[type=checkbox][class~=case-contact-contact-type]").each do |checkbox|
        expect(checkbox).to be_checked
      end
    end

    context "a casa case with contact type" do
      let(:organization) { build(:casa_org) }
      let(:casa_case_with_contact_type) { create(:casa_case, :with_casa_case_contact_types, casa_org: organization) }
      it "has contact type checked" do
        contact_types = casa_case_with_contact_type.contact_types.map(&:id)
        visit edit_casa_case_path(casa_case_with_contact_type)
        all("input[type=checkbox][class~=case-contact-contact-type]").each do |checkbox|
          if contact_types.include? checkbox.value
            expect(checkbox).to be_checked
          else
            expect(checkbox).not_to be_checked
          end
        end
      end
    end

    it "has all contact types checked on click trigger 'Check All' button", js: true do
      visit edit_casa_case_path(casa_case)
      expect(page).to have_text("Select All Contact Types")
      expect(casa_case.contact_types).to be_empty
      find("a#check_all").click
      expect(all("input[type=checkbox][class~=case-contact-contact-type]")).not_to be_empty
      all("input[type=checkbox][class~=case-contact-contact-type]").each do |checkbox|
        expect(checkbox).to be_checked
      end
    end

    it "has all contact types checked on click trigger 'Uncheck All' button", js: true do
      visit edit_casa_case_path(casa_case)
      expect(page).to have_text("Select All Contact Types")
      expect(casa_case.contact_types).to be_empty
      find("a#uncheck_all").click
      expect(all("input[type=checkbox][class~=case-contact-contact-type]")).not_to be_empty
      all("input[type=checkbox][class~=case-contact-contact-type]").each do |checkbox|
        expect(checkbox).not_to be_checked
      end
    end

    it "raise an error if no contact type is checked", js: true do
      visit edit_casa_case_path(casa_case)
      expect(page).to have_text("Select All Contact Types")
      find("a#uncheck_all").click
      expect(all("input[type=checkbox][class~=case-contact-contact-type]")).not_to be_empty

      within ".actions-cc" do
        click_on "Update CASA Case"
      end

      expect(page).to have_text("At least one contact type must be selected")
    end

    context "when trying to assign a volunteer to a case" do
      it "should be able to assign volunteers", js: true do
        visit edit_casa_case_path(casa_case)

        expect(page).to have_content("Manage Volunteers")
        expect(page).to have_css("#volunteer-assignment")
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
        path_to_template = "app/documents/templates/default_report_template.docx"
        args = {
          volunteer_id: volunteer.id,
          case_id: casa_case.id,
          path_to_template: path_to_template
        }
        context = CaseCourtReportContext.new(args).context
        report = CaseCourtReport.new(path_to_template: path_to_template, context: context)
        casa_case.court_reports.attach(io: StringIO.new(report.generate_to_string), filename: "report#{n}.docx")
        attached_report = casa_case.latest_court_report
        attached_report.created_at = n.days.ago
        attached_report.save!
        attached_report
      end
    end

    let!(:siblings_casa_cases) do
      organization = volunteer.casa_org
      casa_case2 = create(:casa_case, :with_one_court_order, casa_org: organization)
      create(:case_assignment, volunteer: volunteer, casa_case: casa_case2)
      organization.casa_cases.excluding(casa_case)
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
      within ".actions-cc" do
        click_on "Update CASA Case"
      end

      expect(page).not_to have_field("Court Report Due Date")
      expect(page).not_to have_text("Youth's Date in Care")
      expect(page).not_to have_text("Deactivate Case")

      expect(page).to have_css('button[data-action="extended-nested-form#add"]')

      visit casa_case_path(casa_case)
      expect(page).to have_text("Court Report Status: Submitted")
    end

    context "Copy all court orders from a case" do
      it "copy button should be disabled when no case is selected", js: true do
        visit edit_casa_case_path(casa_case)
        expect(page).to have_button("copy-court-button", disabled: true)
      end

      it "copy button should be enabled when a case is selected", js: true do
        visit edit_casa_case_path(casa_case)
        select siblings_casa_cases.first.case_number, from: "casa_case_siblings_casa_cases"
        expect(page).to have_button("copy-court-button", disabled: false)
      end

      it "copy button and select shouldn't be visible when a volunteer only has one case", js: true do
        volunteer = build(:volunteer)
        casa_case = create(:casa_case, :with_one_court_order, casa_org: volunteer.casa_org)
        create(:case_assignment, volunteer: volunteer, casa_case: casa_case)
        visit edit_casa_case_path(casa_case)
        expect(page).not_to have_button("copy-court-button")
        expect(page).not_to have_selector("casa_case_siblings_casa_cases")
      end

      it "should contains all cases associated to current volunteer except current case", js: true do
        visit edit_casa_case_path(casa_case)
        within "#casa_case_siblings_casa_cases" do
          siblings_casa_cases.each do |scc|
            expect(page).to have_selector("option", text: scc.case_number)
          end
          expect(page).not_to have_selector("option", text: casa_case.case_number)
        end
      end

      it "should copy all court orders from selected case", js: true do
        visit casa_case_path(casa_case.id)
        click_on "Edit Case Details"
        selected_case = siblings_casa_cases.first
        select selected_case.case_number, from: "casa_case_siblings_casa_cases"
        click_on "Copy"
        within ".swal2-popup" do
          expect(page).to have_text("Copy all orders from case ##{selected_case.case_number}?")
          click_on "Copy"
        end
        expect(page).to have_text("Court orders have been copied")
        casa_case.reload
        court_orders_text = casa_case.case_court_orders.map(&:text)
        court_orders_status = casa_case.case_court_orders.map(&:implementation_status)
        selected_case.case_court_orders.each do |orders|
          expect(court_orders_text).to include orders.text
          expect(court_orders_status).to include orders.implementation_status
        end
      end

      it "should not overwrite existing court orders", js: true do
        visit casa_case_path(casa_case.id)
        click_on "Edit Case Details"
        selected_case = siblings_casa_cases.first
        current_orders = casa_case.case_court_orders.each(&:dup)
        select selected_case.case_number, from: "casa_case_siblings_casa_cases"
        click_on "Copy"
        within ".swal2-popup" do
          expect(page).to have_text("Copy all orders from case ##{selected_case.case_number}?")
          click_on "Copy"
        end
        expect(page).to have_text("Court orders have been copied")
        casa_case.reload
        current_orders.each do |orders|
          expect(casa_case.case_court_orders.map(&:text)).to include orders.text
        end
        expect(casa_case.case_court_orders.count).to be >= current_orders.count
      end

      it "should not move court orders from one case to another", js: true do
        visit casa_case_path(casa_case.id)
        click_on "Edit Case Details"
        selected_case = siblings_casa_cases.first
        select selected_case.case_number, from: "casa_case_siblings_casa_cases"
        click_on "Copy"
        within ".swal2-popup" do
          expect(page).to have_text("Copy all orders from case ##{selected_case.case_number}?")
          click_on "Copy"
        end
        expect(page).to have_text("Court orders have been copied")
        casa_case.reload
        expect(selected_case.case_court_orders.count).to be > 0
      end
    end
  end
end

def stub_twillio
  twillio_client = instance_double(Twilio::REST::Client)
  messages = instance_double(Twilio::REST::Api::V2010::AccountContext::MessageList)
  allow(Twilio::REST::Client).to receive(:new).with("Aladdin", "open sesame", "articuno34").and_return(twillio_client)
  allow(twillio_client).to receive(:messages).and_return(messages)
  allow(messages).to receive(:list).and_return([])
end
