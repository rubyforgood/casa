require "rails_helper"

RSpec.describe FileImporter, type: :concern do

  describe "#import_volunteers" do

    it "imports volunteers from a csv file" do
      import_user = create(:user, :casa_admin)

      import_file_path = Rails.root.join("spec", "fixtures", "volunteers.csv")
      expect { FileImporter.import_volunteers(import_file_path, import_user.casa_org.id) }.to change(User, :count).by(3)
    end

    it "does not import duplicate volunteers from csv files" do
      import_user = create(:user, :casa_admin)

      import_file_path = Rails.root.join("spec", "fixtures", "volunteers.csv")
      FileImporter.import_volunteers(import_file_path, import_user.casa_org.id)
      expect { FileImporter.import_volunteers(import_file_path, import_user.casa_org.id) }.to change(User, :count).by(0)
    end
  end

  describe "#import_supervisors" do
    it "imports supervisors and associates volunteers with them" do
      import_user = create(:user, :casa_admin)

      import_file_path = Rails.root.join("spec", "fixtures", "volunteers.csv")
      FileImporter.import_volunteers(import_file_path, import_user.casa_org.id)

      import_supervisor_path = Rails.root.join("spec", "fixtures", "supervisors.csv")
      expect { FileImporter.import_supervisors(import_supervisor_path, import_user.casa_org.id) }.to change(User, :count).by(2)

      supervisor = User.find_by(email: "supervisor2@example.net")
      expect(supervisor.volunteers.size).to eq(2)
    end

    it "does not import duplicate supervisors from csv files" do
      import_user = create(:user, :casa_admin)

      import_file_path = Rails.root.join("spec", "fixtures", "volunteers.csv")
      FileImporter.import_volunteers(import_file_path, import_user.casa_org.id)

      import_supervisor_path = Rails.root.join("spec", "fixtures", "supervisors.csv")
      FileImporter.import_supervisors(import_supervisor_path, import_user.casa_org.id)
      expect { FileImporter.import_supervisors(import_supervisor_path, import_user.casa_org.id) }.to change(User, :count).by(0)
    end
  end

  describe "#import_cases" do
    it "imports cases and associates volunteers with them" do
      import_user = create(:user, :casa_admin)

      import_file_path = Rails.root.join("spec", "fixtures", "volunteers.csv")
      FileImporter.import_volunteers(import_file_path, import_user.casa_org.id)

      import_case_path = Rails.root.join("spec", "fixtures", "casa_cases.csv")
      expect { FileImporter.import_cases(import_case_path, import_user.casa_org.id) }.to change(CasaCase, :count).by(2)

      # correctly imports true/false transition_aged_youth
      expect(CasaCase.last.transition_aged_youth).to be_falsey
      expect(CasaCase.first.transition_aged_youth).to be_truthy

      # correctly adds volunteers
      expect(CasaCase.first.volunteers.size).to be(1)
      expect(CasaCase.last.volunteers.size).to be(2)
    end

    it "does not duplicate casa case files from csv files" do
      import_user = create(:user, :casa_admin)

      import_file_path = Rails.root.join("spec", "fixtures", "volunteers.csv")
      FileImporter.import_volunteers(import_file_path, import_user.casa_org.id)

      import_case_path = Rails.root.join("spec", "fixtures", "casa_cases.csv")
      FileImporter.import_cases(import_case_path, import_user.casa_org.id)
      expect { FileImporter.import_cases(import_case_path, import_user.casa_org.id) }.to change(CasaCase, :count).by(0)
    end
  end
end