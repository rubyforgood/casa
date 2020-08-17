require "rails_helper"

RSpec.describe FileImporter, type: :concern do
  describe "#import_volunteers" do
    it "imports volunteers from a csv file" do
      import_user = create(:casa_admin)

      import_file_path = Rails.root.join("spec", "fixtures", "volunteers.csv")
      importer = FileImporter.new(import_file_path, import_user.casa_org.id)
      expect { importer.import_volunteers }.to change(User, :count).by(3)
    end

    it "does not import duplicate volunteers from csv files" do
      import_user = create(:casa_admin)

      import_file_path = Rails.root.join("spec", "fixtures", "volunteers.csv")
      importer = FileImporter.new(import_file_path, import_user.casa_org.id)
      importer.import_volunteers
      expect { importer.import_volunteers }.to change(User, :count).by(0)
    end

    it "returns a success message with the number of volunteers imported" do
      import_user = create(:casa_admin)

      import_file_path = Rails.root.join("spec", "fixtures", "volunteers.csv")
      importer = FileImporter.new(import_file_path, import_user.casa_org.id)
      alert = importer.import_volunteers
      expect(alert[:type]).to eq(:success)
      expect(alert[:message]).to eq("You successfully imported 3 volunteers.")
    end

    it "returns an error message when there are volunteers not imported" do
      import_user = create(:casa_admin)

      import_file_path = Rails.root.join("spec", "fixtures", "volunteers.csv")
      FileImporter.new(import_file_path, import_user.casa_org.id).import_volunteers

      alert = FileImporter.new(import_file_path, import_user.casa_org.id).import_volunteers
      expect(alert[:type]).to eq(:error)
      expect(alert[:message]).to include("You successfully imported 0 volunteers, the following volunteers were not")
    end
  end

  describe "#import_supervisors" do
    it "imports supervisors and associates volunteers with them" do
      import_user = create(:casa_admin)

      import_file_path = Rails.root.join("spec", "fixtures", "volunteers.csv")
      FileImporter.new(import_file_path, import_user.casa_org.id).import_volunteers

      import_supervisor_path = Rails.root.join("spec", "fixtures", "supervisors.csv")
      supervisor_importer = FileImporter.new(import_supervisor_path, import_user.casa_org.id)

      expect { supervisor_importer.import_supervisors }.to change(Supervisor, :count).by(3)

      expect(Supervisor.find_by(email: "supervisor1@example.net").volunteers.size).to eq(1)
      expect(Supervisor.find_by(email: "supervisor2@example.net").volunteers.size).to eq(2)
      expect(Supervisor.find_by(email: "supervisor3@example.net").volunteers.size).to eq(0)
    end

    it "does not import duplicate supervisors from csv files" do
      import_user = create(:casa_admin)

      import_file_path = Rails.root.join("spec", "fixtures", "volunteers.csv")
      FileImporter.new(import_file_path, import_user.casa_org.id).import_volunteers

      import_supervisor_path = Rails.root.join("spec", "fixtures", "supervisors.csv")
      supervisor_importer = FileImporter.new(import_supervisor_path, import_user.casa_org.id)

      supervisor_importer.import_supervisors

      expect { supervisor_importer.import_supervisors }.to change(Supervisor, :count).by(0)
    end

    it "returns a success message with the number of supervisors imported" do
      import_user = create(:casa_admin)

      import_file_path = Rails.root.join("spec", "fixtures", "volunteers.csv")
      FileImporter.new(import_file_path, import_user.casa_org.id).import_volunteers

      import_supervisor_path = Rails.root.join("spec", "fixtures", "supervisors.csv")
      supervisor_importer = FileImporter.new(import_supervisor_path, import_user.casa_org.id)

      alert = supervisor_importer.import_supervisors
      expect(alert[:type]).to eq(:success)
      expect(alert[:message]).to eq("You successfully imported 3 supervisors.")
    end

    it "returns an error message when there are volunteers not imported" do
      import_user = create(:casa_admin)

      import_file_path = Rails.root.join("spec", "fixtures", "volunteers.csv")
      FileImporter.new(import_file_path, import_user.casa_org.id).import_volunteers

      import_supervisor_path = Rails.root.join("spec", "fixtures", "supervisors.csv")
      FileImporter.new(import_supervisor_path, import_user.casa_org.id).import_supervisors

      alert = FileImporter.new(import_file_path, import_user.casa_org.id).import_supervisors
      expect(alert[:type]).to eq(:error)
      expect(alert[:message]).to include("You successfully imported 0 supervisors, the following supervisors were not")
    end
  end

  describe "#import_cases" do
    it "imports cases and associates volunteers with them" do
      import_user = create(:casa_admin)

      import_file_path = Rails.root.join("spec", "fixtures", "volunteers.csv")
      FileImporter.new(import_file_path, import_user.casa_org.id).import_volunteers

      import_case_path = Rails.root.join("spec", "fixtures", "casa_cases.csv")
      expect { FileImporter.new(import_case_path, import_user.casa_org.id).import_cases }.to change(CasaCase, :count).by(3)

      # correctly imports true/false transition_aged_youth
      expect(CasaCase.find_by(case_number: "CINA-01-4347").transition_aged_youth).to be_truthy
      expect(CasaCase.find_by(case_number: "CINA-01-4348").transition_aged_youth).to be_falsey
      expect(CasaCase.find_by(case_number: "CINA-01-4349").transition_aged_youth).to be_falsey

      # correctly adds volunteers
      expect(CasaCase.find_by(case_number: "CINA-01-4347").volunteers.size).to eq(1)
      expect(CasaCase.find_by(case_number: "CINA-01-4348").volunteers.size).to eq(2)
      expect(CasaCase.find_by(case_number: "CINA-01-4349").volunteers.size).to eq(0)
    end

    it "does not duplicate casa case files from csv files" do
      import_user = create(:casa_admin)

      import_file_path = Rails.root.join("spec", "fixtures", "volunteers.csv")
      FileImporter.new(import_file_path, import_user.casa_org.id).import_volunteers

      import_case_path = Rails.root.join("spec", "fixtures", "casa_cases.csv")
      FileImporter.new(import_case_path, import_user.casa_org.id).import_cases

      expect { FileImporter.new(import_case_path, import_user.casa_org.id).import_cases }.to change(CasaCase, :count).by(0)
    end

    it "returns a success message with the number of cases imported" do
      import_user = create(:casa_admin)

      import_file_path = Rails.root.join("spec", "fixtures", "volunteers.csv")
      FileImporter.new(import_file_path, import_user.casa_org.id).import_volunteers

      import_case_path = Rails.root.join("spec", "fixtures", "casa_cases.csv")
      case_importer = FileImporter.new(import_case_path, import_user.casa_org.id)

      alert = case_importer.import_cases
      expect(alert[:type]).to eq(:success)
      expect(alert[:message]).to eq("You successfully imported 3 casa_cases.")
    end

    it "returns an error message when there are cases not imported" do
      import_user = create(:casa_admin)

      import_file_path = Rails.root.join("spec", "fixtures", "volunteers.csv")
      FileImporter.new(import_file_path, import_user.casa_org.id).import_volunteers

      import_case_path = Rails.root.join("spec", "fixtures", "casa_cases.csv")
      FileImporter.new(import_case_path, import_user.casa_org.id).import_cases

      alert = FileImporter.new(import_case_path, import_user.casa_org.id).import_cases
      expect(alert[:type]).to eq(:error)
      expect(alert[:message]).to include("You successfully imported 0 casa_cases, the following casa_cases were not")
    end
  end
end
