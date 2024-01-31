require "rails_helper"

RSpec.describe "/case_court_reports", type: :request do
  include DownloadHelpers
  let(:volunteer) { create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor) }

  before do
    sign_in volunteer
  end

  # case_court_reports#index
  describe "GET /case_court_reports" do
    context "as volunteer" do
      it "can view 'Generate Court Report' page", :aggregate_failures do
        get case_court_reports_path
        expect(response).to be_successful
        expect(assigns(:assigned_cases)).to_not be_empty
      end
    end

    context "as a supervisor" do
      let(:supervisor) { volunteer.supervisor }

      before do
        sign_in supervisor
      end

      it "can view the 'Generate Court Report' page", :aggregate_failures do
        get case_court_reports_path
        expect(response).to be_successful
        expect(assigns(:assigned_cases)).to_not be_empty
      end

      context "with no cases in the organization" do
        let(:supervisor) { create(:supervisor, casa_org: create(:casa_org)) }

        it "can view 'Generate Court Report page", :aggregate_failures do
          get case_court_reports_path
          expect(response).to be_successful
          expect(assigns(:assigned_cases)).to be_empty
        end
      end
    end
  end

  # case_court_reports#show
  describe "GET /case_court_reports/:id" do
    context "when a valid / existing case is sent" do
      let(:casa_case) { volunteer.casa_cases.first }

      before do
        Tempfile.create do |t|
          casa_case.court_reports.attach(
            io: File.open(t.path), filename: "#{casa_case.case_number}.docx"
          )
        end
      end

      subject(:request) do
        get case_court_report_path(casa_case.case_number, format: "docx")

        response
      end

      it "authorizes action" do
        expect_any_instance_of(CaseCourtReportsController).to receive(:authorize).with(CaseCourtReport).and_call_original
        request
      end

      it "send response as a .DOCX file" do
        expect(request.content_type).to eq Mime::Type.lookup_by_extension(:docx)
      end

      it "send response with a status :ok" do
        expect(request).to have_http_status(:ok)
      end
    end

    context "when an INVALID / non-existing case is sent" do
      let(:invalid_casa_case) { build_stubbed(:casa_case) }

      before do
        Capybara.current_driver = :selenium_chrome
        get case_court_report_path(invalid_casa_case.case_number, format: "docx")
      end

      it "redirects back to 'Generate Court Report' page", :aggregate_failures, js: true do
        expect(response).to redirect_to(case_court_reports_path)
        expect(response.content_type).to eq "text/html; charset=utf-8"
      end

      it "shows correct flash message" do
        request
        expect(flash[:alert]).to eq "Report #{invalid_casa_case.case_number} is not found."
      end
    end
  end

  # case_court_reports#generate
  describe "POST /case_court_reports" do
    let(:casa_case) { volunteer.casa_cases.first }
    let(:params) { {case_court_report: {case_number: casa_case.case_number.to_s}} }

    subject(:request) do
      post generate_case_court_reports_path, params: params, headers: {ACCEPT: "application/json"}

      response
    end

    it "authorizes action" do
      expect_any_instance_of(CaseCourtReportsController).to receive(:authorize).with(CaseCourtReport).and_call_original
      request
    end

    context "when no custom template is set" do
      it "sends response as a JSON string", :aggregate_failures do
        expect(request.content_type).to eq("application/json; charset=utf-8")
        expect(request.parsed_body).to be_a(ActiveSupport::HashWithIndifferentAccess)
      end

      it "has keys ['link', 'status'] in JSON string", :aggregate_failures do
        body_hash = request.parsed_body

        expect(body_hash).to have_key "link"
        expect(body_hash).to have_key "status"
      end

      it "sends response with status :ok" do
        expect(request).to have_http_status(:ok)
      end

      it "contains a link ending with .DOCX extension" do
        expect(request.parsed_body["link"]).to end_with(".docx")
      end

      it "uses the default template" do
        get request.parsed_body["link"]

        docx_response = Docx::Document.open(StringIO.new(response.body))

        expect(header_text(docx_response)).to include("YOUR CASA ORG’S NUMBER")
      end
    end

    context "when a custom template is set" do
      before do
        stub_twillio
        volunteer.casa_org.court_report_template.attach(io: File.new(Rails.root.join("app", "documents", "templates", "montgomery_report_template.docx")), filename: "montgomery_report_template.docx")
      end

      it "uses the custom template" do
        get request.parsed_body["link"]
        followed_link_response = response

        docx_response = Docx::Document.open(StringIO.new(followed_link_response.body))

        expect(docx_response.paragraphs.map(&:to_s)).to include("Did you forget to enter your court orders?")
      end
    end

    context "when user timezone" do
      let(:server_time) { Time.zone.parse("2020-12-31 23:00:00") }
      let(:user_different_timezone) do
        ActiveSupport::TimeZone["Tokyo"]
      end
      let(:params) { {case_court_report: {case_number: casa_case.case_number.to_s}, time_zone: "Tokyo"} }

      before do
        travel_to server_time
      end

      it "is different than server" do
        get request.parsed_body["link"]
        followed_link_response = response

        docx_response = Docx::Document.open(StringIO.new(followed_link_response.body))

        expect(docx_response.paragraphs.map(&:to_s)).to include("Date Written: #{I18n.l(user_different_timezone.at(server_time).to_date, format: :full, default: nil)}")
      end
    end

    context "when an INVALID / non-existing case is sent" do
      let(:casa_case) { build_stubbed(:casa_case) }

      it "sends response as a JSON string", :aggregate_failures do
        expect(request.content_type).to eq("application/json; charset=utf-8")
        expect(request.parsed_body).to be_a(ActiveSupport::HashWithIndifferentAccess)
      end

      it "has keys ['link','status','error_messages'] in JSON string", :aggregate_failures do
        body_hash = request.parsed_body

        expect(body_hash).to have_key "link"
        expect(body_hash).to have_key "status"
        expect(body_hash).to have_key "error_messages"
      end

      it "sends response with status :not_found" do
        expect(request).to have_http_status(:not_found)
      end

      it "contains a empty link" do
        expect(request.parsed_body["link"].length).to be 0
      end

      # TODO: Fix controller to have the error message actually get the param with `case_params[:case_number]`
      it "shows correct error messages" do
        expect(request.parsed_body["error_messages"]).to include("Report  is not found")
      end
    end

    context "when zip report fails" do
      before do
        expect_any_instance_of(CaseCourtReportsController).to receive(:save_report).and_raise Zip::Error.new
      end

      it { is_expected.to have_http_status(:not_found) }

      it "shows the correct error message" do
        expect(request.parsed_body["error_messages"]).to include("Template is not found")
      end
    end

    context "when an unpredictable error occurs" do
      before do
        expect_any_instance_of(CaseCourtReportsController).to receive(:save_report).and_raise StandardError.new("Unexpected Error")
      end

      it { is_expected.to have_http_status(:unprocessable_entity) }

      it "shows the correct error message" do
        expect(request.parsed_body["error_messages"]).to include("Unexpected Error")
      end
    end
  end
end

def stub_twillio
  twillio_client = instance_double(Twilio::REST::Client)
  messages = instance_double(Twilio::REST::Api::V2010::AccountContext::MessageList)
  allow(Twilio::REST::Client).to receive(:new).with("Aladdin", "open sesame", "articuno34").and_return(twillio_client)
  allow(twillio_client).to receive(:messages).and_return(messages)
  allow(messages).to receive(:list).and_return([])
end
