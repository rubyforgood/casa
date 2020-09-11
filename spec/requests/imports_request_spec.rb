require "rails_helper"

RSpec.describe "/imports", type: :request do
  let(:volunteer_file) { Rails.root.join("spec", "fixtures", "volunteers.csv") }
  let(:supervisor_file) { Rails.root.join("spec", "fixtures", "supervisors.csv") }
  let(:supervisor_volunteers_file) { Rails.root.join("spec", "fixtures", "supervisor_volunteers.csv") }
  let(:casa_admin) { create(:casa_admin) }

  describe "GET /index" do
    it "renders an unsuccessful response when the user is not an admin" do
      sign_in create(:volunteer)

      get imports_url

      expect(response).to_not be_successful
    end

    it "renders a successful response when the user is an admin" do
      sign_in casa_admin

      get imports_url

      expect(response).to be_successful
    end

    it "creates volunteers in volunteer CSV imports" do
      sign_in casa_admin

      expect(Volunteer.count).to eq(0)

      expect {
        post imports_url,
          params: {
            import_type: "volunteer",
            file: fixture_file_upload(volunteer_file)
          }
      }.to change(Volunteer, :count).by(3)

      expect(response).to redirect_to(imports_url(import_type: "volunteer"))
    end

    it "creates supervisors and adds volunteers in supervisor CSV imports" do
      sign_in casa_admin

      # make sure appropriate volunteers exist
      UserImporter.import_volunteers(volunteer_file, casa_admin.casa_org_id)

      expect(Supervisor.count).to eq(0)

      expect {
        post imports_url,
          params: {
            import_type: "supervisor",
            file: fixture_file_upload(supervisor_file)
          }
      }.to change(Supervisor, :count).by(3)

      expect(Supervisor.find_by(email: "supervisor1@example.net").volunteers.size).to eq(1)
      expect(Supervisor.find_by(email: "supervisor2@example.net").volunteers.size).to eq(2)
      expect(Supervisor.find_by(email: "supervisor3@example.net").volunteers.size).to eq(0)

      expect(response).to redirect_to(imports_url(import_type: "supervisor"))
    end
    # TODO: Dominique to make test for importing csv for multiple supervisors for 1 volunteer
    it "creates supervisors and assigns the volunteer if not already assigned" do
      sign_in casa_admin

      # make sure appropriate volunteers exist
      UserImporter.new(volunteer_file, casa_admin.casa_org_id).import_volunteers

      expect(Supervisor.count).to eq(0)

      expect {
        post imports_url, {
          params: {
            import_type: "supervisor",
            file: fixture_file_upload(supervisor_volunteers_file)
          }
        }
      }.to change(Supervisor, :count).by(2)

      expect(Supervisor.find_by(email: "s5@example.com").volunteers.size).to eq(1)
      expect(Supervisor.find_by(email: "s6@example.com").volunteers.size).to eq(0)

      expect(response).to redirect_to(imports_url(import_type: "supervisor"))
    end
  end
end
# TODO: dominique test for message success/fail
