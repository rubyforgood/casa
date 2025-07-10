require "rails_helper"

RSpec.describe "/imports", type: :request do
  let(:volunteer_file) { fixture_file_upload "volunteers.csv", "text/csv" }
  let(:supervisor_file) { fixture_file_upload "supervisors.csv", "text/csv" }
  let(:case_file) { fixture_file_upload "casa_cases.csv", "text/csv" }
  let(:existing_case_file) { fixture_file_upload "existing_casa_case.csv", "text/csv" }
  let(:supervisor_volunteers_file) { fixture_file_upload "supervisor_volunteers.csv", "text/csv" }
  let(:casa_admin) { build(:casa_admin) }
  let(:pre_transition_aged_youth_age) { Date.current - 14.years }

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
        file: supervisor_file,
        sms_opt_in: "1"
      }

      expect(request.session[:import_error]).to include("Expected", VolunteerImporter::IMPORT_HEADER.join(", "))
      expect(response).to redirect_to(imports_url(import_type: "volunteer"))
    end

    it "validates supervisors CSV header" do
      sign_in casa_admin

      post imports_url, params: {
        import_type: "supervisor",
        file: volunteer_file,
        sms_opt_in: "1"
      }

      expect(request.session[:import_error]).to include("Expected", SupervisorImporter::IMPORT_HEADER.join(", "))
      expect(response).to redirect_to(imports_url(import_type: "supervisor"))
    end

    it "validates cases CSV header" do
      sign_in casa_admin

      post imports_url, params: {
        import_type: "casa_case",
        file: supervisor_file,
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
            file: volunteer_file,
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
            file: supervisor_file,
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
            file: supervisor_volunteers_file,
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
            file: case_file,
            sms_opt_in: "1"
          }
      }.to change(CasaCase, :count).by(3)

      expect(CasaCase.first.next_court_date).not_to be_nil
      expect(CasaCase.last.next_court_date).to be_nil

      expect(response).to redirect_to(imports_url(import_type: "casa_case"))
    end

    it "produces an error when a deactivated case already exists in cases CSV imports" do
      sign_in casa_admin

      create(:casa_case, case_number: "CINA-00-0000", birth_month_year_youth: pre_transition_aged_youth_age, active: "false")

      expect(CasaCase.count).to eq(1)

      expect {
        post imports_url,
          params: {
            import_type: "casa_case",
            file: existing_case_file
          }
      }.not_to change(CasaCase, :count)

      expect(request.session[:import_error]).to include("Not all rows were imported.")
      expect(response).to redirect_to(imports_url(import_type: "casa_case"))

      failed_csv_path = Rails.root.join("tmp", "casa_case", "failed_rows_userid_#{casa_admin.id}.csv")
      expect(File.exist?(failed_csv_path)).to be true

      file_contents = File.read(failed_csv_path)
      expect(file_contents).to include("Case CINA-00-0000 already exists, but is inactive. Reactivate the CASA case instead.")

      FileUtils.rm_f(failed_csv_path) # Cleanup
    end

    it "calls FailedImportCsv#store when there are failed rows from the import" do
      sign_in casa_admin

      csv_service_double = instance_double(FailedImportCsv)
      allow(csv_service_double).to receive(:failed_rows=)
      allow(csv_service_double).to receive(:store)
      allow(csv_service_double).to receive(:cleanup)
      allow(FailedImportCsv).to receive(:new).and_return(csv_service_double)

      allow(CaseImporter).to receive(:import_cases).and_return({
        message: "Some cases were not imported.",
        exported_rows: "Case CINA-00-0000 already exists, but is inactive. Reactivate the CASA case instead.",
        type: :error
      })

      expect(csv_service_double).to receive(:failed_rows=).with("Case CINA-00-0000 already exists, but is inactive. Reactivate the CASA case instead.")
      expect(csv_service_double).to receive(:store)
      expect(csv_service_double).to receive(:cleanup)

      post imports_url,
        params: {
          import_type: "casa_case",
          file: fixture_file_upload("existing_casa_case.csv", "text/csv")
        }

      expect(request.session[:import_error]).to include("Click here to download failed rows.")
      expect(response).to redirect_to(imports_url(import_type: "casa_case"))
    end

    it "writes a fallback message when exported rows exceed max size" do
      sign_in casa_admin

      large_exported_content = "a" * (FailedImportCsv::MAX_FILE_SIZE_BYTES + 1)

      allow(CaseImporter).to receive(:import_cases).and_return({
        message: "Some rows were too large.",
        exported_rows: large_exported_content,
        type: :error
      })

      post imports_url,
        params: {
          import_type: "casa_case",
          file: case_file
        }

      failed_csv_path = Rails.root.join("tmp", "casa_case", "failed_rows_userid_#{casa_admin.id}.csv")
      expect(File.exist?(failed_csv_path)).to be true

      written_content = File.read(failed_csv_path)
      expect(written_content).to include("CSV too large to save for user=#{casa_admin.id}")

      expect(request.session[:import_error]).to include("Click here to download failed rows.")

      FileUtils.rm_f(failed_csv_path) # Cleanup
    end
  end
end
