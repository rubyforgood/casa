require "rails_helper"

RSpec.describe VolunteerImporter do
  let!(:import_user) { build(:casa_admin) }
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

    specify "static and instance methods have identical results" do
      VolunteerImporter.new(import_file_path, casa_org_id).import_volunteers
      data_using_instance = Volunteer.pluck(:email).sort

      SentEmail.destroy_all
      Volunteer.destroy_all
      VolunteerImporter.import_volunteers(import_file_path, casa_org_id)
      data_using_static = Volunteer.pluck(:email).sort

      expect(data_using_static).to eq(data_using_instance)
      expect(data_using_static).to_not be_empty
    end
  end

  context "when updating volunteers" do
    let!(:existing_volunteer) { create(:volunteer, display_name: "&&&&&", email: "volunteer1@example.net") }

    it "updates outdated volunteer fields" do
      expect {
        volunteer_importer.call
        existing_volunteer.reload
      }.to change(existing_volunteer, :display_name).to("Volunteer One")
    end

    it "updates phone number to valid number and turns sms notifications on" do
      expect {
        volunteer_importer.call
        existing_volunteer.reload
      }.to change(existing_volunteer, :phone_number).to("+11234567890")
        .and change(existing_volunteer, :receive_sms_notifications).to(true)
    end
  end

  context "when row doesn't have e-mail address" do
    let(:import_file_path) { Rails.root.join("spec", "fixtures", "volunteers_without_email.csv") }

    it "returns an error message" do
      alert = volunteer_importer.call

      expect(alert[:type]).to eq(:error)
      expect(alert[:message]).to eq("You successfully imported 1 volunteers. Not all rows were imported.")
      expect(alert[:exported_rows]).to include("Row does not contain an e-mail address.")
    end
  end

  context "when row doesn't have phone number" do
    let(:import_file_path) { Rails.root.join("spec", "fixtures", "volunteers_without_phone_numbers.csv") }

    let!(:existing_volunteer_with_number) { create(:volunteer, display_name: "#", email: "volunteer2@example.net", phone_number: "+11111111111", receive_sms_notifications: true) }

    it "updates phone number to be deleted and turns sms notifications off" do
      expect {
        volunteer_importer.call
        existing_volunteer_with_number.reload
      }.to change(existing_volunteer_with_number, :phone_number).to("")
        .and change(existing_volunteer_with_number, :receive_sms_notifications).to(false)
    end
  end

  context "when phone number in row is invalid" do
    let(:import_file_path) { Rails.root.join("spec", "fixtures", "volunteers_invalid_phone_numbers.csv") }

    it "returns an error message" do
      alert = volunteer_importer.call

      expect(alert[:type]).to eq(:error)
      expect(alert[:message]).to eq("Not all rows were imported.")
      expect(alert[:exported_rows]).to include("Phone number must be 12 digits including country code (+1)")
    end
  end
end
