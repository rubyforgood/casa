require "rails_helper"

RSpec.describe VolunteerImporter do
  let!(:import_user) { create(:casa_admin) }
  let(:casa_org_id) { import_user.casa_org.id }

  # Use of the static method VolunteerImporter.import_volunteers functions identically to VolunteerImporter.new(...).import_volunteers
  # but is preferred.
  let(:import_file_path) { Rails.root.join("spec", "fixtures", "volunteers.csv") }
  let(:volunteer_importer) { -> { VolunteerImporter.import_volunteers(import_file_path, casa_org_id) } }

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
      alert = VolunteerImporter.import_volunteers(import_file_path, import_user.casa_org.id)
      expect(alert[:type]).to eq(:error)
      expect(alert[:message]).to include("Not all rows were imported.")
    end

    specify "static and instance methods have identical results" do
      VolunteerImporter.new(import_file_path, casa_org_id).import_volunteers
      data_using_instance = Volunteer.pluck(:email).sort

      Volunteer.delete_all
      VolunteerImporter.import_volunteers(import_file_path, casa_org_id)
      data_using_static = Volunteer.pluck(:email).sort

      expect(data_using_static).to eq(data_using_instance)
      expect(data_using_static).to_not be_empty
    end
  end
end
