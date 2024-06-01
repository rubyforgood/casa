require "rails_helper"
require "csv"
RSpec.describe CaseContactReport, type: :model do
  describe "#generate_headers" do
    it "matches the length of row data" do
      create(:case_contact)
      csv = described_class.new.to_csv
      parsed_csv = CSV.parse(csv, headers: true)

      expect(parsed_csv.length).to eq(1) # length doesn't include header row
      expect(parsed_csv.headers).to eq([
        "Internal Contact Number",
        "Duration Minutes",
        "Contact Types",
        "Contact Made",
        "Contact Medium",
        "Occurred At",
        "Added To System At",
        "Miles Driven",
        "Wants Driving Reimbursement",
        "Casa Case Number",
        "Creator Email",
        "Creator Name",
        "Supervisor Name",
        "Case Contact Notes"
      ])

      case_contact_data = parsed_csv.first
      expect(parsed_csv.headers.length).to eq(case_contact_data.length)
    end
  end

  describe "CSV body serialization" do
    let!(:long_case_contact) { create(:case_contact, :long_note) }
    let!(:multi_line_case_contact) { create(:case_contact, :multi_line_note, casa_case: long_case_contact.casa_case) }

    subject { CaseContactReport.new(casa_org_id: long_case_contact.casa_case.casa_org.id).to_csv }

    it "includes entire note" do
      expect(subject).to include(long_case_contact.notes)
      expect(subject).to include(multi_line_case_contact.notes)
    end
  end

  describe "filter behavior" do
    describe "casa organization" do
      let(:casa_org) { create(:casa_org) }
      let(:casa_case) { create(:casa_case, casa_org: casa_org) }
      let(:case_contact) { create(:case_contact, casa_case: casa_case) }

      it "includes case contacts from current org" do
        report = CaseContactReport.new(casa_org_id: casa_org.id)

        expect(report.case_contacts).to contain_exactly(case_contact)
      end

      context "from other orgs" do
        let(:other_casa_org) { create(:casa_org) }
        let(:casa_case) { create(:casa_case, casa_org: other_casa_org) }

        it "excludes case contacts" do
          report = CaseContactReport.new(casa_org_id: casa_org.id)

          expect(report.case_contacts).to be_empty
        end
      end
    end

    context "when result is empty" do
      it "returns only headers if result is empty" do
        report = CaseContactReport.new(
          {
            "start_date" => 1.days.ago,
            "end_date" => 1.days.ago,
            "contact_made" => true,
            "has_transitioned" => true,
            "want_driving_reimbursement" => true,
            "contact_type_ids" => ["4"],
            "contact_type_group_ids" => ["2", "3"],
            "supervisor_ids" => ["2"]
          }
        )
        contacts = report.case_contacts

        expect(report.to_csv).to eq(
          "Internal Contact Number,Duration Minutes,Contact Types,Contact Made,Contact Medium,Occurred At,Added To System At,Miles Driven,Wants Driving Reimbursement,Casa Case Number,Creator Email,Creator Name,Supervisor Name,Case Contact Notes\n"
        )
        expect(contacts.length).to eq(0)
      end
    end

    context "when result is not empty" do
      describe "occured at range filter" do
        it "uses date range if provided" do
          create(:case_contact, {occurred_at: 20.days.ago})
          build(:case_contact, {occurred_at: 100.days.ago})
          report = CaseContactReport.new({start_date: 30.days.ago, end_date: 10.days.ago})
          contacts = report.case_contacts
          expect(contacts.length).to eq(1)
        end

        it "returns all date ranges if not provided" do
          create(:case_contact, {occurred_at: 20.days.ago})
          create(:case_contact, {occurred_at: 100.days.ago})
          report = CaseContactReport.new({})
          contacts = report.case_contacts
          expect(contacts.length).to eq(2)
        end

        it "returns only the volunteer" do
          volunteer = create(:volunteer)
          create(:case_contact, {occurred_at: 20.days.ago, creator_id: volunteer.id})
          build(:case_contact, {occurred_at: 100.days.ago})
          report = CaseContactReport.new({creator_ids: [volunteer.id]})
          contacts = report.case_contacts
          expect(contacts.length).to eq(1)
        end

        it "returns only the volunteer with date range" do
          volunteer = create(:volunteer)
          create(:case_contact, {occurred_at: 20.days.ago, creator_id: volunteer.id})
          create(:case_contact, {occurred_at: 100.days.ago, creator_id: volunteer.id})

          build(:case_contact, {occurred_at: 100.days.ago})
          report = CaseContactReport.new({start_date: 30.days.ago, end_date: 10.days.ago, creator_ids: [volunteer.id]})
          contacts = report.case_contacts
          expect(contacts.length).to eq(1)
        end

        it "returns only the volunteer with the specified supervisors" do
          casa_org = build(:casa_org)
          supervisor = create(:supervisor, casa_org: casa_org)
          volunteer = build(:volunteer, casa_org: casa_org)
          volunteer2 = create(:volunteer, casa_org: casa_org)
          create(:supervisor_volunteer, volunteer: volunteer, supervisor: supervisor)

          contact = create(:case_contact, {occurred_at: 20.days.ago, creator_id: volunteer.id})
          build_stubbed(:case_contact, {occurred_at: 100.days.ago, creator_id: volunteer2.id})

          build_stubbed(:case_contact, {occurred_at: 100.days.ago})
          report = CaseContactReport.new({supervisor_ids: [supervisor.id]})
          contacts = report.case_contacts
          expect(contacts.length).to eq(1)
          expect(contacts).to eq([contact])
        end
      end
    end

    describe "case contact behavior" do
      before(:each) do
        create(:case_contact, {contact_made: true})
        create(:case_contact, {contact_made: false})
      end

      it "returns only the case contacts with where contact was made" do
        report = CaseContactReport.new({contact_made: true})
        contacts = report.case_contacts
        expect(contacts.length).to eq(1)
      end

      it "returns only the case contacts with where contact was NOT made" do
        report = CaseContactReport.new({contact_made: false})
        contacts = report.case_contacts
        expect(contacts.length).to eq(1)
      end

      it "returns only the case contacts with where contact was made or NOT made" do
        report = CaseContactReport.new({contact_made: [true, false]})
        contacts = report.case_contacts
        expect(contacts.length).to eq(2)
      end
    end

    describe "has transitioned behavior" do
      let(:case_case_1) { create(:casa_case, birth_month_year_youth: 15.years.ago) }
      let(:case_case_2) { create(:casa_case, birth_month_year_youth: 10.years.ago) }

      before(:each) do
        create(:case_contact, {casa_case: case_case_1})
        create(:case_contact, {casa_case: case_case_2})
      end

      it "returns only case contacts the youth has transitioned" do
        contacts = CaseContactReport.new(has_transitioned: false).case_contacts

        expect(contacts.length).to eq(1)
      end

      it "returns only case contacts the youth has transitioned" do
        contacts = CaseContactReport.new(has_transitioned: true).case_contacts

        expect(contacts.length).to eq(1)
      end

      it "returns case contacts with both youth has transitioned and youth has not transitioned" do
        contacts = CaseContactReport.new(has_transitioned: "").case_contacts

        expect(contacts.length).to eq(2)
      end
    end

    describe "wanting driving reimbursement functionality" do
      before(:each) do
        create(:case_contact, {miles_driven: 50, want_driving_reimbursement: true})
        create(:case_contact, {miles_driven: 50, want_driving_reimbursement: false})
      end

      it "returns only contacts that want reimbursement" do
        report = CaseContactReport.new({want_driving_reimbursement: true})
        contacts = report.case_contacts
        expect(contacts.length).to eq(1)
      end

      it "returns only contacts that DO NOT want reimbursement" do
        report = CaseContactReport.new({want_driving_reimbursement: false})
        contacts = report.case_contacts
        expect(contacts.length).to eq(1)
      end

      it "returns contacts that both want reimbursement and do not want reimbursement" do
        report = CaseContactReport.new({want_driving_reimbursement: ""})
        contacts = report.case_contacts
        expect(contacts.length).to eq(2)
      end
    end

    describe "contact type filter functionality" do
      it "returns only the case contacts that include the case contact" do
        casa_org = build(:casa_org)
        supervisor = create(:supervisor, casa_org: casa_org)
        volunteer = build(:volunteer, casa_org: casa_org)
        volunteer2 = create(:volunteer, casa_org: casa_org)
        court = build(:contact_type, name: "Court")
        school = build_stubbed(:contact_type, name: "School")
        create(:supervisor_volunteer, volunteer: volunteer, supervisor: supervisor)

        contact = create(:case_contact, {occurred_at: 20.days.ago, creator_id: volunteer.id, contact_types: [court]})
        build_stubbed(:case_contact, {occurred_at: 100.days.ago, creator_id: volunteer2.id, contact_types: [school]})
        build_stubbed(:case_contact, {occurred_at: 100.days.ago})
        report = CaseContactReport.new({contact_type_ids: [court.id]})
        contacts = report.case_contacts
        expect(contacts.length).to eq(1)
        expect(contacts).to eq([contact])
      end
    end

    describe "contact type group filter functionality" do
      before do
        casa_org = build(:casa_org)
        supervisor = create(:supervisor, casa_org: casa_org)
        volunteer = build(:volunteer, casa_org: casa_org)
        volunteer2 = create(:volunteer, casa_org: casa_org)
        create(:supervisor_volunteer, volunteer: volunteer, supervisor: supervisor)

        @contact_type_group = build(:contact_type_group, name: "Legal")
        legal_court = build_stubbed(:contact_type, name: "Court", contact_type_group: @contact_type_group)
        legal_attorney = build(:contact_type, name: "Attorney", contact_type_group: @contact_type_group)
        placement_school = build_stubbed(:contact_type, name: "School", contact_type_group: build(:contact_type_group, name: "Placement"))

        @expected_contact = create(:case_contact, {occurred_at: 20.days.ago, creator_id: volunteer.id, contact_types: [legal_court, legal_attorney]})
        create(:case_contact, {occurred_at: 100.days.ago, creator_id: volunteer2.id, contact_types: [placement_school]})
        create(:case_contact, {occurred_at: 100.days.ago})
      end

      context "3 contacts each with 1 contact type groups: Legal, Placement and 1 random" do
        context "when select 1 contact type group" do
          it "returns 1 case contact whose contact_types belong to that group" do
            report = CaseContactReport.new(
              {contact_type_group_ids: [@contact_type_group.id]}
            )
            expect(report.case_contacts.length).to eq(1)
            expect(report.case_contacts).to eq([@expected_contact])
          end
        end

        context "when select prompt option (value is empty) and 1 contact type group" do
          it "returns 1 case contact whose contact_types belong to that group" do
            report = CaseContactReport.new(
              {contact_type_group_ids: ["", @contact_type_group.id, ""]}
            )
            expect(report.case_contacts.length).to eq(1)
            expect(report.case_contacts).to eq([@expected_contact])
          end
        end

        context "when select ONLY prompt option (value is empty) and NO contact type group" do
          it "does no filtering & returns 3 case contacts" do
            report = CaseContactReport.new(
              {contact_type_group_ids: [""]}
            )
            expect(report.case_contacts.length).to eq(3)
            expect(report.case_contacts).to eq(CaseContact.all)
          end
        end

        context "when select nothing on Case Type Group" do
          it "does no filtering & returns 3 case contacts" do
            report = CaseContactReport.new(
              {contact_type_group_ids: nil}
            )
            expect(report.case_contacts.length).to eq(3)
            expect(report.case_contacts).to eq(CaseContact.all)
          end
        end
      end
    end

    describe "casa case number filter" do
      let!(:casa_case) { create(:casa_case) }
      let!(:case_contacts) { create_list(:case_contact, 3, casa_case: casa_case) }

      before { create_list(:case_contact, 8) }

      context "when providing casa case ids" do
        it "returns all case contacts with the casa case ids" do
          report = described_class.new({casa_case_ids: [casa_case.id]})
          expect(report.case_contacts.length).to eq(case_contacts.length)
          expect(report.case_contacts).to match_array(case_contacts)
        end
      end

      context "when not providing casa case ids" do
        it "return all case contacts" do
          report = described_class.new({casa_case_ids: nil})
          expect(report.case_contacts.length).to eq(CaseContact.count)
          expect(report.case_contacts).to eq(CaseContact.all)
        end
      end
    end

    describe "multiple filter behavior" do
      it "only returns records that occured less than 30 days ago, the youth has transitioned, and the contact type was either court or therapist" do
        court = build(:contact_type, name: "Court")
        school = build(:contact_type, name: "School")
        therapist = build(:contact_type, name: "Therapist")
        untransitioned_casa_case = create(:casa_case, :pre_transition)
        transitioned_casa_case = create(:casa_case)
        contact1 = create(:case_contact, occurred_at: 20.days.ago, casa_case: transitioned_casa_case, contact_types: [court])
        build_stubbed(:case_contact, occurred_at: 40.days.ago, casa_case: transitioned_casa_case, contact_types: [court])
        build_stubbed(:case_contact, occurred_at: 20.days.ago, casa_case: untransitioned_casa_case, contact_types: [court])
        contact4 = create(:case_contact, occurred_at: 20.days.ago, casa_case: transitioned_casa_case, contact_types: [school])
        contact5 = create(:case_contact, occurred_at: 20.days.ago, casa_case: transitioned_casa_case, contact_types: [court, school])
        contact6 = create(:case_contact, occurred_at: 20.days.ago, casa_case: transitioned_casa_case, contact_types: [therapist])

        aggregate_failures do
          report_1 = CaseContactReport.new({start_date: 30.days.ago, end_date: 10.days.ago, has_transitioned: true, contact_type_ids: [court.id]})
          expect(report_1.case_contacts.length).to eq(2)
          expect((report_1.case_contacts - [contact1, contact5]).empty?).to eq(true)

          report_2 = CaseContactReport.new({start_date: 30.days.ago, end_date: 10.days.ago, has_transitioned: true, contact_type_ids: [school.id]})
          expect(report_2.case_contacts.length).to eq(2)
          expect((report_2.case_contacts - [contact4, contact5]).empty?).to eq(true)

          report_3 = CaseContactReport.new({start_date: 30.days.ago, end_date: 10.days.ago, has_transitioned: true, contact_type_ids: [therapist.id]})
          expect(report_3.case_contacts.length).to eq(1)
          expect(report_3.case_contacts.include?(contact6)).to eq(true)
        end
      end
    end

    context "when columns are filtered" do
      let(:args) do
        {
          filtered_csv_cols: {
            internal_contact_number: "true",
            duration_minutes: "true",
            contact_types: "false"
          }
        }
      end

      it "returns a report with only the selected columns" do
        create(:case_contact)
        csv = described_class.new(args).to_csv
        parsed_csv = CSV.parse(csv)

        expect(parsed_csv.length).to eq(2)
        expect(parsed_csv[0]).to eq([
          "Internal Contact Number",
          "Duration Minutes"
        ])
      end
    end
  end

  context "with court topics" do
    let(:used_topic)   { create(:contact_topic, question: "Used topic") }
    let(:unused_topic) { create(:contact_topic, question: "Unused topic") }

    let(:contacts) { create_list(:case_contact, 3) }

    before do
      create(:contact_topic_answer, case_contact: contacts.first,  contact_topic: used_topic, value: "Yes!")
      create(:contact_topic_answer, case_contact: contacts.second, contact_topic: used_topic, value: "Nope")
    end

    let(:report) { described_class.new }
    let(:csv)    { CSV.parse(report.to_csv, headers: true) }

    it "appends headers for any topics referenced by case_contacts in the report" do
      headers = csv.headers
      expect(headers).not_to include(unused_topic.question)
      expect(headers).to include(used_topic.question)
      expect(headers.select { |header| header == used_topic.question }.size).to be 1
    end

    it "includes topic answers in csv rows" do
      expect(csv["Used topic"]).to match_array ["Yes!", "Nope", nil]
    end
  end
end
