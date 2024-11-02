require "rails_helper"
require_relative "../support/upload_helpers"

RSpec.describe "/imports" do
  include UploadHelpers

  let(:volunteer_file) { Rails.root.join("spec/fixtures/volunteers.csv") }
  let(:supervisor_file) { Rails.root.join("spec/fixtures/supervisors.csv") }
  let(:case_file) { Rails.root.join("spec/fixtures/casa_cases.csv") }
  let(:existing_case_file) { Rails.root.join("spec/fixtures/existing_casa_case.csv") }
  let(:supervisor_volunteers_file) { Rails.root.join("spec/fixtures/supervisor_volunteers.csv") }
  let(:casa_org) { create(:casa_org) }
  let(:casa_admin) { build(:casa_admin, casa_org:) }

  before do
    # next_court_date in casa_cases.csv needs to be a future date
    travel_to Date.parse("Sept 15 2022")
  end

  describe "GET /index" do
    it "renders an unsuccessful response when the user is not an admin" do
      sign_in create(:volunteer)

      get imports_url

      expect(response).not_to be_successful
    end

    it "renders a successful response when the user is an admin" do
      sign_in casa_admin

      get imports_url

      expect(response).to be_successful
    end

    it "validates volunteers CSV header" do
      sign_in casa_admin

      post imports_url, params: {
        import_type: "volunteer",
        file: upload_file(supervisor_file),
        sms_opt_in: "1"
      }

      expect(request.session[:import_error]).to include("Expected", VolunteerImporter::IMPORT_HEADER.join(", "))
      expect(response).to redirect_to(imports_url(import_type: "volunteer"))
    end

    it "validates supervisors CSV header" do
      sign_in casa_admin

      post imports_url, params: {
        import_type: "supervisor",
        file: upload_file(volunteer_file),
        sms_opt_in: "1"
      }

      expect(request.session[:import_error]).to include("Expected", SupervisorImporter::IMPORT_HEADER.join(", "))
      expect(response).to redirect_to(imports_url(import_type: "supervisor"))
    end

    it "validates cases CSV header" do
      sign_in casa_admin

      post imports_url, params: {
        import_type: "casa_case",
        file: upload_file(supervisor_file),
        sms_opt_in: "1"
      }

      expect(request.session[:import_error]).to include("Expected", CaseImporter::IMPORT_HEADER.join(", "))
      expect(response).to redirect_to(imports_url(import_type: "casa_case"))
    end

    it "creates volunteers in volunteer CSV imports" do
      sign_in casa_admin

      expect(Volunteer.count).to eq(0)

      expect {
        post imports_url,
          params: {
            import_type: "volunteer",
            file: upload_file(volunteer_file),
            sms_opt_in: "1"
          }
      }.to change(Volunteer, :count).by(3)

      expect(response).to redirect_to(imports_url(import_type: "volunteer"))
    end

    it "creates supervisors and adds volunteers in supervisor CSV imports" do
      sign_in casa_admin

      # make sure appropriate volunteers exist
      VolunteerImporter.import_volunteers(volunteer_file, casa_admin.casa_org_id)

      expect(Supervisor.count).to eq(0)

      expect {
        post imports_url,
          params: {
            import_type: "supervisor",
            file: upload_file(supervisor_file),
            sms_opt_in: "1"
          }
      }.to change(Supervisor, :count).by(3)

      expect(Supervisor.find_by(email: "supervisor1@example.net").volunteers.size).to eq(1)
      expect(Supervisor.find_by(email: "supervisor2@example.net").volunteers.size).to eq(2)
      expect(Supervisor.find_by(email: "supervisor3@example.net").volunteers.size).to eq(0)

      expect(response).to redirect_to(imports_url(import_type: "supervisor"))
    end

    it "creates supervisors and assigns the volunteer if not already assigned" do
      sign_in casa_admin

      # make sure appropriate volunteers exist
      VolunteerImporter.new(volunteer_file, casa_admin.casa_org_id).import_volunteers

      expect(Supervisor.count).to eq(0)

      expect {
        post imports_url,
          params: {
            import_type: "supervisor",
            file: upload_file(supervisor_volunteers_file),
            sms_opt_in: "1"
          }
      }.to change(Supervisor, :count).by(2)

      expect(Supervisor.find_by(email: "s5@example.com").volunteers.size).to eq(1)
      expect(Supervisor.find_by(email: "s6@example.com").volunteers.size).to eq(0)

      expect(response).to redirect_to(imports_url(import_type: "supervisor"))
    end

    it "creates case in cases CSV imports and adds next court date" do
      sign_in casa_admin

      expect(CasaCase.count).to eq(0)

      expect {
        post imports_url,
          params: {
            import_type: "casa_case",
            file: upload_file(case_file),
            sms_opt_in: "1"
          }
      }.to change(CasaCase, :count).by(3)

      expect(CasaCase.first.next_court_date).not_to be_nil
      expect(CasaCase.last.next_court_date).to be_nil

      expect(response).to redirect_to(imports_url(import_type: "casa_case"))
    end

    it "produces an error when a deactivated case already exists in cases CSV imports" do
      sign_in casa_admin

      create(:casa_case, :pre_transition, case_number: "CINA-00-0000", active: "false")

      expect(CasaCase.count).to eq(1)

      expect {
        post imports_url,
          params: {
            import_type: "casa_case",
            file: upload_file(existing_case_file)
          }
      }.not_to change(CasaCase, :count)

      expect(request.session[:import_error]).to include("Not all rows were imported.")
      expect(request.session[:exported_rows]).to include("Case CINA-00-0000 already exists, but is inactive. Reactivate the CASA case instead.")
      expect(response).to redirect_to(imports_url(import_type: "casa_case"))
    end
  end
end
