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
        report = CaseContactReport.new({creator_id: volunteer.id})
        contacts = report.case_contacts
        expect(contacts.length).to eq(1)
      end
      it "returns only the volunteer with date range" do
        volunteer = create(:volunteer)
        create(:case_contact, {occurred_at: 20.days.ago, creator_id: volunteer.id})
        create(:case_contact, {occurred_at: 100.days.ago, creator_id: volunteer.id})
       
        create(:case_contact, {occurred_at: 100.days.ago})
        report = CaseContactReport.new({start_date: 30.days.ago, end_date: 10.days.ago, creator_id: volunteer.id})
        contacts = report.case_contacts
        expect(contacts.length).to eq(1)
      end
      it "returns only the volunteer with the specified supervisors" do
        supervisor = create(:supervisor)
        volunteer = create(:volunteer)
        volunteer2 = create(:volunteer)
        supervisor_volunteer = create(:supervisor_volunteer, volunteer: volunteer, supervisor: supervisor)
        
        create(:case_contact, {occurred_at: 20.days.ago, creator_id: volunteer.id})
        create(:case_contact, {occurred_at: 100.days.ago, creator_id: volunteer2.id})
       
        create(:case_contact, {occurred_at: 100.days.ago})
        report = CaseContactReport.new({supervisor_ids: [supervisor.id]})
        contacts = report.case_contacts
        # expect(contacts.length).to eq(1)
      end
      it "returns only the volunteer with the specified supervisors" do
        supervisor = create(:supervisor)
        volunteer = create(:volunteer)
        volunteer2 = create(:volunteer)
        supervisor_volunteer = create(:supervisor_volunteer, volunteer: volunteer, supervisor: supervisor)
        
        create(:case_contact, {creator_id: volunteer.id})
        create(:case_contact, {creator_id: volunteer2.id})
       
        report = CaseContactReport.new({supervisor_ids: [supervisor.id]})
        contacts = report.case_contacts
        expect(contacts.length).to eq(1)
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
        it "returns only case contacts the youth has transitioned" do
          case_case_1 = create(:casa_case, transition_aged_youth: false)
          case_case_2 = create(:casa_case, transition_aged_youth: true)
          create(:case_contact, {casa_case: case_case_1})
          create(:case_contact, {casa_case: case_case_2})
          report = CaseContactReport.new({has_transitioned: [true, false]})
          contacts = report.case_contacts
          expect(contacts.length).to eq(2)
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
        it "returns all contacts that specify whether they want reimbursement or not" do
          create(:case_contact, {miles_driven: 50, want_driving_reimbursement: true})
          create(:case_contact, {miles_driven: 50, want_driving_reimbursement: false})

          report = CaseContactReport.new({want_driving_reimbursement: [true, false]})
          contacts = report.case_contacts
          expect(contacts.length).to eq(2)
        end
      end
      # describe "contact type filter functionality" do
      #   it "returns only the case contacts that include the case contact" do
      #     supervisor = create(:supervisor)
      #     volunteer = create(:volunteer)
      #     volunteer2 = create(:volunteer)
      #     supervisor_volunteer = create(:supervisor_volunteer, volunteer: volunteer, supervisor: supervisor)
          
      #     create(:case_contact, {occurred_at: 20.days.ago, creator_id: volunteer.id, contact_types: ["court"]})
      #     create(:case_contact, {occurred_at: 100.days.ago, creator_id: volunteer2.id, contact_types: ["school"]})
        
      #     create(:case_contact, {occurred_at: 100.days.ago})
      #     report = CaseContactReport.new({contact_types: ["court"]})
      #     contacts = report.case_contacts
      #     expect(contacts.length).to eq(1)
      #   end
      # end
      describe "multiple filter behavior" do
        it "only returns records that occured less than 30 days ago, the youth has transitioned, and the contact type was either court or therapist" do
          create(:case_contact, occurred_at: 20.days.ago, has_transitioned: true, contact_types: ["court"])
          create(:case_contact, occurred_at: 40.days.ago, has_transitioned: true, contact_types: ["court"])
          create(:case_contact, occurred_at: 20.days.ago, has_transitioned: false, contact_types: ["court"])
          create(:case_contact, occurred_at: 20.days.ago, has_transitioned: true, contact_types: ["school"])
          create(:case_contact, occurred_at: 20.days.ago, has_transitioned: true, contact_types: ["court", "school"])
          create(:case_contact, occurred_at: 20.days.ago, has_transitioned: true, contact_types: ["therapist"])

          20_days_ago_court_transitioned_report = CaseContactReport.new({start_date: 30.days.ago, end_date: 10.days.ago, has_transitioned: true, contact_types: ["court"] })
          contacts = 20_days_ago_court_transitioned_report.case_contacts
          expect(contacts.length).to eq(1)

        end
      end
    end
  end
end
