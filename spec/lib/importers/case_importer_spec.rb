require "rails_helper"

RSpec.describe CaseImporter do
  subject(:case_importer) { CaseImporter.new(import_file_path, casa_org_id) }

  let(:casa_org) { create :casa_org }
  let(:casa_org_id) { casa_org.id }
  let(:import_file_path) { file_fixture "casa_cases.csv" }

  before do
    allow(case_importer).to receive(:email_addresses_to_users) do |_clazz, comma_separated_emails|
      create_list(:volunteer, comma_separated_emails.split(",").size, casa_org_id: casa_org_id)
    end

    # next_court_date in casa_cases.csv needs to be a future date
    travel_to Date.parse("Sept 15 2022")
  end

  describe "#import_cases" do
    it "imports cases and associates volunteers with them" do
      expect { case_importer.import_cases }.to change(CasaCase, :count).by(3)

      # correctly imports birth_month_year_youth
      expect(CasaCase.find_by(case_number: "CINA-01-4347").birth_month_year_youth&.strftime("%Y-%m-%d")).to eql "2011-03-01"
      expect(CasaCase.find_by(case_number: "CINA-01-4348").birth_month_year_youth&.strftime("%Y-%m-%d")).to eql "2000-02-01"
      expect(CasaCase.find_by(case_number: "CINA-01-4349").birth_month_year_youth&.strftime("%Y-%m-%d")).to eql "2016-12-01"

      # correctly adds volunteers
      expect(CasaCase.find_by(case_number: "CINA-01-4347").volunteers.size).to eq(1)
      expect(CasaCase.find_by(case_number: "CINA-01-4348").volunteers.size).to eq(2)
      expect(CasaCase.find_by(case_number: "CINA-01-4349").volunteers.size).to eq(0)

      # correctly adds next court date
      expect(CasaCase.find_by(case_number: "CINA-01-4348").next_court_date.date.strftime("%Y-%m-%d")).to eql "2023-01-01"
      expect(CasaCase.find_by(case_number: "CINA-01-4347").next_court_date.date.strftime("%Y-%m-%d")).to eql "2022-09-16"
      expect(CasaCase.find_by(case_number: "CINA-01-4349").next_court_date).to be_nil
    end

    context "when updating records" do
      let!(:existing_case) { create(:casa_case, case_number: "CINA-01-4348") }

      it "assigns new volunteers to the case" do
        expect { case_importer.import_cases }.to change(existing_case.volunteers, :count).by(2)
      end

      it "updates outdated case fields" do
        expect {
          case_importer.import_cases
          existing_case.reload
        }.to change(existing_case, :birth_month_year_youth).to(Date.new(2000, 2, 1))
      end

      it "adds a next court date" do
        expect {
          case_importer.import_cases
          existing_case.reload
        }.to change(existing_case, :court_dates).from([])
      end
    end

    it "returns a success message with the number of cases imported" do
      alert = case_importer.import_cases

      expect(alert[:type]).to eq(:success)
      expect(alert[:message]).to eq("You successfully imported 3 casa_cases.")
    end

    specify "static and instance methods have identical results" do
      CaseImporter.new(import_file_path, casa_org_id).import_cases
      data_using_instance = CasaCase.pluck(:case_number).sort

      CourtDate.delete_all
      CasaCase.delete_all
      CaseImporter.import_cases(import_file_path, casa_org_id)
      data_using_static = CasaCase.pluck(:case_number).sort

      expect(data_using_static).to eq(data_using_instance)
      expect(data_using_static).not_to be_empty
    end

    context "when the importer has already run once" do
      before { case_importer.import_cases }

      it "does not duplicate casa case files from csv files" do
        expect { case_importer.import_cases }.not_to change(CasaCase, :count)
      end
    end

    context "when there's no case number" do
      let(:import_file_path) { file_fixture "casa_cases_without_case_number.csv" }

      it "returns an error message if row does not contain a case number" do
        alert = case_importer.import_cases

        expect(alert[:type]).to eq(:error)
        expect(alert[:message]).to eq("You successfully imported 1 casa_cases. Not all rows were imported.")
        expect(alert[:exported_rows]).to include("Row does not contain a case number.")
      end
    end
  end
end
