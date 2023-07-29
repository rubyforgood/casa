require "rails_helper"

RSpec.describe CaseCourtReportsController, type: :controller do
  describe "GET index" do
    context "when volunteer" do
      it "successfully accesses 'Generate Court Report' page" do
        current_user = create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor)

        sign_in current_user

        get :index

        expect(response).to have_http_status(:ok)
        expect(response).to render_template :index
        expect(assigns(:assigned_cases)).not_to be_empty
      end
    end

    context "when supervisor" do
      it "successfully accesses 'Generate Court Report' page" do
        current_user = create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor)

        sign_in current_user

        get :index

        expect(response).to have_http_status(:ok)
        expect(response).to render_template :index
        expect(assigns(:assigned_cases)).not_to be_empty
      end

      context "when there's no case in the organization" do
        it "successfully accesses 'Generate Court Report' page" do
          current_user = create(:supervisor, casa_org: create(:casa_org))

          sign_in current_user

          get :index

          expect(response).to have_http_status(:ok)
          expect(response).to render_template :index
          expect(assigns(:assigned_cases)).to be_empty
        end
      end
    end
  end

  describe "GET show" do
    context "when the case is valid" do
      let(:volunteer) { create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor) }
      let(:casa_case) { volunteer.casa_cases.first }

      before do
        Tempfile.create do |t|
          casa_case.court_reports.attach(
            io: File.open(t.path), filename: "#{casa_case.case_number}.docx"
          )
        end
      end

      context "when volunteer" do
        it "sends DOCX file in response with a success status" do
          sign_in volunteer

          get :show, params: {id: casa_case.case_number, format: "docx"}

          expect(response.content_type).to eq Mime::Type.lookup_by_extension(:docx)
          expect(response).to have_http_status(:ok)
        end
      end

      context "when supervisor" do
        it "sends DOCX file in response with aa success status" do
          sign_in volunteer.supervisor

          get :show, params: {id: casa_case.case_number, format: "docx"}

          expect(response.content_type).to eq Mime::Type.lookup_by_extension(:docx)
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context "when the case is invalid" do
      let(:volunteer) { create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor) }

      let(:invalid_casa_case) { build_stubbed(:casa_case) }

      context "when volunteer" do
        it "redirects back to 'Generate Court Report' page" do
          sign_in volunteer

          get :show, params: {id: invalid_casa_case.case_number, format: "docx"}

          expect(response).to redirect_to(case_court_reports_path)
          expect(response.content_type).to eq "text/html; charset=utf-8"
        end
      end

      context "when supervisor" do
        it "redirects back to 'Generate Court Report' page" do
          sign_in volunteer.supervisor

          get :show, params: {id: invalid_casa_case.case_number, format: "docx"}

          expect(response).to redirect_to(case_court_reports_path)
          expect(response.content_type).to eq "text/html; charset=utf-8"
        end
      end
    end
  end

  describe "POST generate" do
    context "when case is valid" do
      let(:volunteer) { create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor) }
      let(:casa_case) { volunteer.casa_cases.first }

      context "when volunteer" do
        context "when a custom template is not set" do
          before do
            sign_in volunteer

            request.headers["ACCEPT"] = "application/json"

            post :generate, params: {
              case_court_report: {case_number: casa_case.case_number.to_s}
            }
          end

          it "sends response as a JSON string" do
            expect(response.content_type).to eq("application/json; charset=utf-8")
            expect(JSON.parse(response.body)).to be_instance_of Hash
          end

          it "has keys ['link', 'status'] in JSON string" do
            body_hash = JSON.parse(response.body)

            expect(body_hash).to have_key "link"
            expect(body_hash).to have_key "status"
          end

          it "sends response with status :ok" do
            expect(response).to have_http_status(:ok)
          end

          it "contains a link ending with .DOCX extension" do
            body_hash = JSON.parse(response.body)

            expect(body_hash["link"]).to end_with(".docx")
          end

          it "uses the default template" do
            link_parts = JSON.parse(response.body)["link"].split("/")
            case_number = link_parts[link_parts.length - 1].sub(".docx", "")

            get :show, params: {id: case_number, format: "docx"}

            zip = download_docx.zip
            files = zip.glob("word/header*.xml").map { |h| h.name }
            filename_and_contents_pairs = files.map do |file|
              simple_file_name = file.sub(/^word\//, "").sub(/\.xml$/, "")
              [simple_file_name, Nokogiri::XML(@zip.read(file))]
            end

            header_text = filename_and_contents_pairs.map { |name, doc| doc.text }.join("\n")

            expect(header_text).to include("YOUR CASA ORG’S NUMBER")
          end
        end
        context "when a custom template is set" do
          before do
            stub_twillio
            volunteer.casa_org.court_report_template.attach(io: File.new(Rails.root.join("app", "documents", "templates", "montgomery_report_template.docx")), filename: "montgomery_report_template.docx")

            sign_in volunteer

            request.headers["ACCEPT"] = "application/json"

            post :generate, params: {
              case_court_report: {case_number: casa_case.case_number.to_s}
            }
          end

          it "uses the custom template" do
            link_parts = JSON.parse(response.body)["link"].split("/")
            case_number = link_parts[link_parts.length - 1].sub(".docx", "")

            get :show, params: {id: case_number, format: "docx"}

            expect(download_docx.paragraphs.map(&:to_s)).to include("Did you forget to enter your court orders?")
          end
        end
      end

      context "when supervisor" do
        context "when a custom template is not set" do
          before do
            sign_in volunteer.supervisor

            request.headers["ACCEPT"] = "application/json"

            post :generate, params: {
              case_court_report: {case_number: casa_case.case_number.to_s}
            }
          end

          it "sends response as a JSON string" do
            expect(response.content_type).to eq("application/json; charset=utf-8")
            expect(JSON.parse(response.body)).to be_instance_of Hash
          end

          it "has keys ['link', 'status'] in JSON string" do
            body_hash = JSON.parse(response.body)

            expect(body_hash).to have_key "link"
            expect(body_hash).to have_key "status"
          end

          it "sends response with status :ok" do
            expect(response).to have_http_status(:ok)
          end

          it "contains a link ending with .DOCX extension" do
            body_hash = JSON.parse(response.body)

            expect(body_hash["link"]).to end_with(".docx")
          end

          it "uses the default template" do
            link_parts = JSON.parse(response.body)["link"].split("/")
            case_number = link_parts[link_parts.length - 1].sub(".docx", "")

            get :show, params: {id: case_number, format: "docx"}

            expect(download_docx.paragraphs.map(&:to_s)).to include("YOUR CASA ORG’S NUMBER")
          end
        end
        context "when a custom template is set" do
          before do
            stub_twillio
            volunteer.casa_org.court_report_template.attach(io: File.new(Rails.root.join("app", "documents", "templates", "montgomery_report_template.docx")), filename: "montgomery_report_template.docx")

            sign_in volunteer.supervisor

            request.headers["ACCEPT"] = "application/json"

            post :generate, params: {
              case_court_report: {case_number: casa_case.case_number.to_s}
            }
          end

          it "uses the custom template" do
            link_parts = JSON.parse(response.body)["link"].split("/")
            case_number = link_parts[link_parts.length - 1].sub(".docx", "")

            get :show, params: {id: case_number, format: "docx"}

            expect(download_docx.paragraphs.map(&:to_s)).to include("Did you forget to enter your court orders?")
          end
        end
      end
    end

    context "when case is invalid" do
      let(:volunteer) { create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor) }
      let(:casa_case) { build_stubbed(:casa_case) }

      context "when volunteer" do
        before do
          sign_in volunteer

          request.headers["ACCEPT"] = "application/json"

          post :generate, params: {
            case_court_report: {case_number: casa_case.case_number.to_s}
          }
        end

        it "sends response as a JSON string" do
          expect(response.content_type).to eq("application/json; charset=utf-8")
          expect(JSON.parse(response.body)).to be_instance_of Hash
        end

        it "has keys ['link','status','error_messages'] in JSON string" do
          body_hash = JSON.parse(response.body)

          expect(body_hash).to have_key "link"
          expect(body_hash).to have_key "status"
          expect(body_hash).to have_key "error_messages"
        end

        it "sends response with status :not_found" do
          expect(response).to have_http_status(:not_found)
        end

        it "contains a empty link" do
          body_hash = JSON.parse(response.body)

          expect(body_hash["link"].length).to be 0
        end
      end

      context "when supervisor" do
        before do
          sign_in volunteer.supervisor

          request.headers["ACCEPT"] = "application/json"

          post :generate, params: {
            case_court_report: {case_number: casa_case.case_number.to_s}
          }
        end

        it "sends response as a JSON string" do
          expect(response.content_type).to eq("application/json; charset=utf-8")
          expect(JSON.parse(response.body)).to be_instance_of Hash
        end

        it "has keys ['link','status','error_messages'] in JSON string" do
          body_hash = JSON.parse(response.body)

          expect(body_hash).to have_key "link"
          expect(body_hash).to have_key "status"
          expect(body_hash).to have_key "error_messages"
        end

        it "sends response with status :not_found" do
          expect(response).to have_http_status(:not_found)
        end

        it "contains a empty link" do
          body_hash = JSON.parse(response.body)

          expect(body_hash["link"].length).to be 0
        end
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
