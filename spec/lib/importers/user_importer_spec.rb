require "rails_helper"

RSpec.describe UserImporter do
  let!(:import_user) { create(:casa_admin) }
  let(:casa_org_id) { import_user.casa_org.id }

  # Use of the static method UserImporter.import_volunteers functions identically to UserImporter.new(...).import_volunteers
  # but is preferred.
  describe "#import_volunteers" do
    let(:import_file_path) { Rails.root.join("spec", "fixtures", "volunteers.csv") }
    let(:volunteer_importer) { -> { UserImporter.import_volunteers(import_file_path, casa_org_id) } }

    it "imports volunteers from a csv file" do
      expect { volunteer_importer.call }.to change(User, :count).by(3)
    end

    it "returns a success message with the number of volunteers imported" do
      alert = volunteer_importer.call
      expect(alert[:type]).to eq(:success)
      expect(alert[:message]).to eq("You successfully imported 3 volunteers.")
    end

    context "when the volunteers have been imported already" do
      before { volunteer_importer.call }

      it "does not import duplicate volunteers from csv files" do
        expect { volunteer_importer.call }.to change(User, :count).by(0)
      end

      it "returns an error message when there are volunteers not imported" do
        alert = UserImporter.import_volunteers(import_file_path, import_user.casa_org.id)
        expect(alert[:type]).to eq(:error)
        expect(alert[:message]).to include("You successfully imported 0 volunteers. The following volunteers were not")
      end

      specify "static and instance methods have identical results" do
        UserImporter.new(import_file_path, casa_org_id).import_volunteers
        data_using_instance = Volunteer.pluck(:email).sort

        Volunteer.delete_all
        UserImporter.import_volunteers(import_file_path, casa_org_id)
        data_using_static = Volunteer.pluck(:email).sort

        expect(data_using_static).to eq(data_using_instance)
        expect(data_using_static).to_not be_empty
      end
    end
  end

  # Use of the static method UserImporter.import_supervisors functions identically to
  # UserImporter.new(...).import_supervisors, but is preferred. However, it cannot be used for these tests
  # beaause of the allow...to...receive used here.
  describe "#import_supervisors" do
    let(:import_file_path) { Rails.root.join("spec", "fixtures", "supervisors.csv") }

    let(:supervisor_importer) do
      importer = UserImporter.new(import_file_path, casa_org_id)
      allow(importer).to receive(:email_addresses_to_users) do |clazz, supervisor_volunteers|
        create_list(:volunteer, supervisor_volunteers.split(",").size)
      end
      importer
    end

    it "imports supervisors and associates volunteers with them" do
      expect { supervisor_importer.import_supervisors }.to change(Supervisor, :count).by(3)
      expect(Supervisor.find_by(email: "supervisor1@example.net").volunteers.size).to eq(1)
      expect(Supervisor.find_by(email: "supervisor2@example.net").volunteers.size).to eq(2)
      expect(Supervisor.find_by(email: "supervisor3@example.net").volunteers.size).to eq(0)
    end

    it "returns a success message with the number of supervisors imported" do
      alert = supervisor_importer.import_supervisors
      expect(alert[:type]).to eq(:success)
      expect(alert[:message]).to eq("You successfully imported 3 supervisors.")
    end

    context "when the supervisors have already been imported" do
      before { supervisor_importer.import_supervisors }

      it "does not import duplicate supervisors from csv files" do
        expect { supervisor_importer.import_supervisors }.to change(Supervisor, :count).by(0)
      end

      it "returns an error message when there are volunteers not imported" do
        alert = UserImporter.new(import_file_path, import_user.casa_org.id).import_supervisors
        expect(alert[:type]).to eq(:error)
        expect(alert[:message]).to include("You successfully imported 0 supervisors. The following supervisors were not")

        import_user = create(:casa_admin)

        import_file_path = Rails.root.join("spec", "fixtures", "volunteers.csv")
        UserImporter.new(import_file_path, import_user.casa_org.id).import_volunteers

        import_supervisor_path = Rails.root.join("spec", "fixtures", "supervisors.csv")
        UserImporter.new(import_supervisor_path, import_user.casa_org.id).import_supervisors

        alert = UserImporter.new(import_file_path, import_user.casa_org.id).import_supervisors
        expect(alert[:type]).to eq(:error)
        expect(alert[:message]).to include("You successfully imported 0 supervisors. The following supervisors were not")
      end

      it "returns an error message when there are only some volunteers not imported" do
        import_user = create(:casa_admin)
        create(:volunteer, email: "volunteer1@example.net")
        import_supervisor_path = Rails.root.join("spec", "fixtures", "supervisor_volunteers.csv")
        alert = UserImporter.new(import_supervisor_path, import_user.casa_org.id).import_supervisors

        expect(alert[:type]).to eq(:error)
        # expect(alert[:message]).to include("You successfully imported 1 supervisors. The following supervisors were not imported: volunteer1@example.net was not assigned to supervisor s6@example.com on row #2")
        # TODO bring back this functionality
      end
    end

    specify "static and instance methods have identical results" do
      UserImporter.new(import_file_path, casa_org_id).import_supervisors
      data_using_instance = Supervisor.pluck(:email).sort

      Supervisor.delete_all
      UserImporter.import_supervisors(import_file_path, casa_org_id)
      data_using_static = Supervisor.pluck(:email).sort

      expect(data_using_static).to eq(data_using_instance)
      expect(data_using_static).to_not be_empty
    end
  end
end
