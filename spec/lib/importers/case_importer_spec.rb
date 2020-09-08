require "rails_helper"

RSpec.describe CaseImporter do
  let(:casa_org_id) { import_user.casa_org.id }
  subject(:case_importer) { CaseImporter.new(import_file_path, casa_org_id) }
  let!(:import_user) { create(:casa_admin) }
  let(:import_file_path) { Rails.root.join("spec", "fixtures", "casa_cases.csv") }

  before(:each) do
    allow(case_importer).to receive(:gather_users) do |clazz, comma_separated_emails|
      create_list(:volunteer, comma_separated_emails.split(',').size)
    end
  end

  describe "#import_cases" do
    it "imports cases and associates volunteers with them" do
      expect { case_importer.import_cases }.to change(CasaCase, :count).by(3)

      # correctly imports true/false transition_aged_youth
      expect(CasaCase.find_by(case_number: "CINA-01-4347").transition_aged_youth).to be_truthy
      expect(CasaCase.find_by(case_number: "CINA-01-4348").transition_aged_youth).to be_falsey
      expect(CasaCase.find_by(case_number: "CINA-01-4349").transition_aged_youth).to be_falsey

      # correctly adds volunteers
      expect(CasaCase.find_by(case_number: "CINA-01-4347").volunteers.size).to eq(1)
      expect(CasaCase.find_by(case_number: "CINA-01-4348").volunteers.size).to eq(2)
      expect(CasaCase.find_by(case_number: "CINA-01-4349").volunteers.size).to eq(0)
    end

    it "returns a success message with the number of cases imported" do
      alert = case_importer.import_cases
      expect(alert[:type]).to eq(:success)
      expect(alert[:message]).to eq("You successfully imported 3 casa_cases.")
    end

    specify 'static and instance methods have identical results' do
      CaseImporter.new(import_file_path, casa_org_id).import_cases
      data_using_instance = CasaCase.pluck(:case_number).sort

      CasaCase.delete_all
      CaseImporter.import_cases(import_file_path, casa_org_id)
      data_using_static = CasaCase.pluck(:case_number).sort

      expect(data_using_static).to eq(data_using_instance)
      expect(data_using_static).to_not be_empty
    end

    context "when the importer has already run once" do
      before { case_importer.import_cases }
      it "does not duplicate casa case files from csv files" do
        expect { case_importer.import_cases }.to change(CasaCase, :count).by(0)
      end
      it "returns an error message when there are cases not imported" do
        alert = case_importer.import_cases
        expect(alert[:type]).to eq(:error)
        expect(alert[:message]).to include("You successfully imported 0 casa_cases, the following casa_cases were not")
      end
    end
  end
end
