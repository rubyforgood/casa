require "rails_helper"

RSpec.describe "/imports", type: :request do
  let(:volunteer_file) { Rails.root.join("spec", "fixtures", "volunteers.csv") }
  let(:supervisor_file) { Rails.root.join("spec", "fixtures", "supervisors.csv") }
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

      expect do
        post imports_url, {
          params: {
            import_type: "volunteer",
            file: fixture_file_upload(volunteer_file)
          }
        }
      end.to change(Volunteer, :count).by(3)

      expect(response).to redirect_to(imports_url(import_type: 'volunteer'))
    end
# TODO: Dominique to make test for importing csv for multiple supervisors for 1 volunteer
    it "creates supervisors and adds volunteers in supervisor CSV imports" do
      sign_in casa_admin

      # make sure appropriate volunteers exist
      FileImporter.new(volunteer_file, casa_admin.casa_org_id).import_volunteers

      expect(Supervisor.count).to eq(0)

      expect do
        post imports_url, {
          params: {
            import_type: "supervisor",
            file: fixture_file_upload(supervisor_file)
          }
        }
      end.to change(Supervisor, :count).by(3)

      expect(Supervisor.find_by(email: "supervisor1@example.net").volunteers.size).to eq(1)
      expect(Supervisor.find_by(email: "supervisor2@example.net").volunteers.size).to eq(2)
      expect(Supervisor.find_by(email: "supervisor3@example.net").volunteers.size).to eq(0)

      expect(response).to redirect_to(imports_url(import_type: 'supervisor'))
    end
  end
end
