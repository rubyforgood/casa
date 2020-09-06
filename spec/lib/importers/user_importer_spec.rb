require "rails_helper"

RSpec.describe UserImporter do
  let!(:import_user) { create(:casa_admin) }
  let(:casa_org_id) { import_user.casa_org.id }
  let(:user_importer) { UserImporter.new(import_file_path, casa_org_id) }

  describe "#import_volunteers" do
    let(:import_file_path) { Rails.root.join("spec", "fixtures", "volunteers.csv") }

    it "imports volunteers from a csv file" do
      expect { user_importer.import_volunteers }.to change(User, :count).by(3)
    end

    it "returns a success message with the number of volunteers imported" do
      alert = user_importer.import_volunteers
      expect(alert[:type]).to eq(:success)
      expect(alert[:message]).to eq("You successfully imported 3 volunteers.")
    end

    context "when the volunteers have been imported already" do
      before { user_importer.import_volunteers }

      it "does not import duplicate volunteers from csv files" do
        expect { user_importer.import_volunteers }.to change(User, :count).by(0)
      end

      it "returns an error message when there are volunteers not imported" do
        alert = UserImporter.new(import_file_path, import_user.casa_org.id).import_volunteers
        expect(alert[:type]).to eq(:error)
        expect(alert[:message]).to include("You successfully imported 0 volunteers, the following volunteers were not")
      end

      specify 'static and instance methods have identical results' do
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

  describe "#import_supervisors" do
    let(:import_file_path) { Rails.root.join("spec", "fixtures", "supervisors.csv") }

    before(:each) do
      allow(user_importer).to receive(:gather_users) do |clazz, supervisor_volunteers|
        create_list(:volunteer, supervisor_volunteers.split(',').size)
      end
    end

    it "imports supervisors and associates volunteers with them" do
      expect { user_importer.import_supervisors }.to change(Supervisor, :count).by(3)
      expect(Supervisor.find_by(email: "supervisor1@example.net").volunteers.size).to eq(1)
      expect(Supervisor.find_by(email: "supervisor2@example.net").volunteers.size).to eq(2)
      expect(Supervisor.find_by(email: "supervisor3@example.net").volunteers.size).to eq(0)
    end

    it "returns a success message with the number of supervisors imported" do
      alert = user_importer.import_supervisors
      expect(alert[:type]).to eq(:success)
      expect(alert[:message]).to eq("You successfully imported 3 supervisors.")
    end

    context "when the supervisors have already been imported" do
      before { user_importer.import_supervisors }

      it "does not import duplicate supervisors from csv files" do
        expect { user_importer.import_supervisors }.to change(Supervisor, :count).by(0)
      end

      it "returns an error message when there are volunteers not imported" do
        alert = UserImporter.new(import_file_path, import_user.casa_org.id).import_supervisors
        expect(alert[:type]).to eq(:error)
        expect(alert[:message]).to include("You successfully imported 0 supervisors, the following supervisors were not")
      end
    end

    specify 'static and instance methods have identical results' do
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
