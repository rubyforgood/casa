require "rails_helper"
require "csv"
RSpec.describe CaseContactReport, type: :model do
  describe "#generate_headers" do
    it "matches the length of row data" do
      create(:case_contact)
      csv = described_class.new.to_csv
      parsed_csv = CSV.parse(csv)

      expect(parsed_csv.length).to eq(2)
      expect(parsed_csv[0].length).to eq(parsed_csv[1].length)
      expect(parsed_csv[0]).to eq([
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
      case_contact_data = parsed_csv[1]
      expect(case_contact_data[1]).to eq("60")
    end
  end
  describe "filter behavior" do
    describe "occured at range filter" do
      it "uses date range if provided" do
        create(:case_contact, {occurred_at: 20.days.ago})
        create(:case_contact, {occurred_at: 100.days.ago})
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
        create(:case_contact, {occurred_at: 100.days.ago})
        report = CaseContactReport.new({creator_ids: [volunteer.id]})
        contacts = report.case_contacts
        expect(contacts.length).to eq(1)
      end
      it "returns only the volunteer with date range" do
        volunteer = create(:volunteer)
        create(:case_contact, {occurred_at: 20.days.ago, creator_id: volunteer.id})
        create(:case_contact, {occurred_at: 100.days.ago, creator_id: volunteer.id})

        create(:case_contact, {occurred_at: 100.days.ago})
        report = CaseContactReport.new({start_date: 30.days.ago, end_date: 10.days.ago, creator_ids: [volunteer.id]})
        contacts = report.case_contacts
        expect(contacts.length).to eq(1)
      end
      it "returns only the volunteer with the specified supervisors" do
        supervisor = create(:supervisor)
        volunteer = create(:volunteer)
        volunteer2 = create(:volunteer)
        create(:supervisor_volunteer, volunteer: volunteer, supervisor: supervisor)

        contact = create(:case_contact, {occurred_at: 20.days.ago, creator_id: volunteer.id})
        create(:case_contact, {occurred_at: 100.days.ago, creator_id: volunteer2.id})

        create(:case_contact, {occurred_at: 100.days.ago})
        report = CaseContactReport.new({supervisor_ids: [supervisor.id]})
        contacts = report.case_contacts
        expect(contacts.length).to eq(1)
        expect(contacts).to eq([contact])
      end
      describe "case contact behavior" do
        it "returns only the case contacts with where contact was made" do
          create(:case_contact, {contact_made: true})
          create(:case_contact, {contact_made: false})

          report = CaseContactReport.new({contact_made: true})
          contacts = report.case_contacts
          expect(contacts.length).to eq(1)
        end
        it "returns only the case contacts with where contact was NOT made" do
          create(:case_contact, {contact_made: true})
          create(:case_contact, {contact_made: false})

          report = CaseContactReport.new({contact_made: false})
          contacts = report.case_contacts
          expect(contacts.length).to eq(1)
        end
        it "returns only the case contacts with where contact was made or NOT made" do
          create(:case_contact, {contact_made: true})
          create(:case_contact, {contact_made: false})

          report = CaseContactReport.new({contact_made: [true, false]})
          contacts = report.case_contacts
          expect(contacts.length).to eq(2)
        end
      end
      describe "has transitioned behavior" do
        it "returns only case contacts the youth has transitioned" do
          case_case_1 = create(:casa_case, transition_aged_youth: false)
          case_case_2 = create(:casa_case, transition_aged_youth: true)
          create(:case_contact, {casa_case: case_case_1})
          create(:case_contact, {casa_case: case_case_2})
          report = CaseContactReport.new({has_transitioned: false})
          contacts = report.case_contacts
          expect(contacts.length).to eq(1)
        end
        it "returns only case contacts the youth has transitioned" do
          case_case_1 = create(:casa_case, transition_aged_youth: false)
          case_case_2 = create(:casa_case, transition_aged_youth: true)
          create(:case_contact, {casa_case: case_case_1})
          create(:case_contact, {casa_case: case_case_2})
          report = CaseContactReport.new({has_transitioned: true})
          contacts = report.case_contacts
          expect(contacts.length).to eq(1)
        end
      end

      describe "wanting driving reimbursement functionality" do
        it "returns only contacts that want reimbursement" do
          # want_driving_reimbursement
          create(:case_contact, {miles_driven: 50, want_driving_reimbursement: true})
          create(:case_contact, {miles_driven: 50, want_driving_reimbursement: false})

          report = CaseContactReport.new({want_driving_reimbursement: true})
          contacts = report.case_contacts
          expect(contacts.length).to eq(1)
        end
        it "returns only contacts that DO NOT want reimbursement" do
          # want_driving_reimbursement
          create(:case_contact, {miles_driven: 50, want_driving_reimbursement: true})
          create(:case_contact, {miles_driven: 50, want_driving_reimbursement: false})

          report = CaseContactReport.new({want_driving_reimbursement: false})
          contacts = report.case_contacts
          expect(contacts.length).to eq(1)
        end
      end

      describe "contact type filter functionality" do
        it "returns only the case contacts that include the case contact" do
          supervisor = create(:supervisor)
          volunteer = create(:volunteer)
          volunteer2 = create(:volunteer)
          create(:supervisor_volunteer, volunteer: volunteer, supervisor: supervisor)

          contact = create(:case_contact, {occurred_at: 20.days.ago, creator_id: volunteer.id, contact_types: ["court"]})
          create(:case_contact, {occurred_at: 100.days.ago, creator_id: volunteer2.id, contact_types: ["school"]})

          create(:case_contact, {occurred_at: 100.days.ago})
          report = CaseContactReport.new({contact_type: "court"})
          contacts = report.case_contacts
          expect(contacts.length).to eq(1)
          expect(contacts).to eq([contact])
        end
      end
      describe "multiple filter behavior" do
        it "only returns records that occured less than 30 days ago, the youth has transitioned, and the contact type was either court or therapist" do
          untransitioned_casa_case = create(:casa_case, transition_aged_youth: false)
          transitioned_casa_case = create(:casa_case, transition_aged_youth: true)
          contact1 = create(:case_contact, occurred_at: 20.days.ago, casa_case: transitioned_casa_case, contact_types: ["court"])
          create(:case_contact, occurred_at: 40.days.ago, casa_case: transitioned_casa_case, contact_types: ["court"])
          create(:case_contact, occurred_at: 20.days.ago, casa_case: untransitioned_casa_case, contact_types: ["court"])
          contact4 = create(:case_contact, occurred_at: 20.days.ago, casa_case: transitioned_casa_case, contact_types: ["school"])
          contact5 = create(:case_contact, occurred_at: 20.days.ago, casa_case: transitioned_casa_case, contact_types: ["court", "school"])
          contact6 = create(:case_contact, occurred_at: 20.days.ago, casa_case: transitioned_casa_case, contact_types: ["therapist"])

          aggregate_failures do
            report_1 = CaseContactReport.new({start_date: 30.days.ago, end_date: 10.days.ago, has_transitioned: true, contact_type: "court"})
            expect(report_1.case_contacts.length).to eq(2)
            expect((report_1.case_contacts - [contact1, contact5]).empty?).to eq(true)

            report_2 = CaseContactReport.new({start_date: 30.days.ago, end_date: 10.days.ago, has_transitioned: true, contact_type: "school"})
            expect(report_2.case_contacts.length).to eq(2)
            expect((report_2.case_contacts - [contact4, contact5]).empty?).to eq(true)

            report_3 = CaseContactReport.new({start_date: 30.days.ago, end_date: 10.days.ago, has_transitioned: true, contact_type: "therapist"})
            expect(report_3.case_contacts.length).to eq(1)
            expect(report_3.case_contacts.include?(contact6)).to eq(true)
          end
        end
      end
    end
  end
end
