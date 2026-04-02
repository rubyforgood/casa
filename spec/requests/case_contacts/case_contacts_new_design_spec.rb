require "rails_helper"

RSpec.describe "/case_contacts_new_design", type: :request do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }

  before { sign_in admin }

  context "when new_case_contact_table flag is disabled" do
    before do
      allow(Flipper).to receive(:enabled?).with(:new_case_contact_table).and_return(false)
    end

    describe "GET /index" do
      it "redirects to case_contacts_path" do
        get case_contacts_new_design_path
        expect(response).to redirect_to(case_contacts_path)
      end

      it "sets an alert message" do
        get case_contacts_new_design_path
        expect(flash[:alert]).to eq("This feature is not available.")
      end
    end
  end

  context "when new_case_contact_table flag is enabled" do
    before do
      allow(Flipper).to receive(:enabled?).with(:new_case_contact_table).and_return(true)
    end

    describe "GET /index" do
      subject(:request) do
        get case_contacts_new_design_path

        response
      end

      let!(:casa_case) { create(:casa_case, casa_org: organization) }
      let!(:past_contact) { create(:case_contact, :active, casa_case: casa_case, occurred_at: 3.weeks.ago) }
      let!(:recent_contact) { create(:case_contact, :active, casa_case: casa_case, occurred_at: 3.days.ago) }
      let!(:draft_contact) { create(:case_contact, casa_case: casa_case, occurred_at: 5.days.ago, status: "started") }

      it { is_expected.to have_http_status(:success) }

      it "lists exactly two active contacts and one draft" do
        doc = Nokogiri::HTML(request.body)
        case_contact_rows = doc.css('[data-testid="case_contact-row"]')
        expect(case_contact_rows.size).to eq(3)
      end

      it "shows the draft badge exactly once" do
        doc = Nokogiri::HTML(request.body)
        expect(doc.css('[data-testid="draft-badge"]').count).to eq(1)
      end

      it "orders contacts by occurred_at desc" do
        body = request.body

        recent_index = body.index(I18n.l(recent_contact.occurred_at, format: :full))
        past_index = body.index(I18n.l(past_contact.occurred_at, format: :full))

        expect(recent_index).to be < past_index
      end
    end

    describe "POST /datatable" do
      let!(:casa_case) { create(:casa_case, casa_org: organization) }
      let!(:case_contact) { create(:case_contact, :active, casa_case: casa_case, occurred_at: 3.days.ago) }

      let(:datatable_params) do
        {
          draw: "1",
          start: "0",
          length: "10",
          search: {value: ""},
          order: {"0" => {column: "0", dir: "desc"}},
          columns: {
            "0" => {name: "occurred_at", orderable: "true"}
          }
        }
      end

      context "when user is authorized" do
        it "returns JSON with case contacts data" do
          post datatable_case_contacts_new_design_path, params: datatable_params, as: :json

          expect(response).to have_http_status(:success)
          expect(response.content_type).to include("application/json")

          json = JSON.parse(response.body, symbolize_names: true)
          expect(json).to have_key(:data)
          expect(json).to have_key(:recordsTotal)
          expect(json).to have_key(:recordsFiltered)
        end

        it "includes case contact in the data array" do
          post datatable_case_contacts_new_design_path, params: datatable_params, as: :json

          json = JSON.parse(response.body, symbolize_names: true)
          expect(json[:data]).to be_an(Array)
          expect(json[:data].first[:id]).to eq(case_contact.id.to_s)
        end

        it "handles search parameter" do
          searchable_contact = create(:case_contact, :active,
            casa_case: casa_case,
            creator: create(:volunteer, display_name: "John Doe", casa_org: organization))

          search_params = datatable_params.merge(search: {value: "John"})
          post datatable_case_contacts_new_design_path, params: search_params, as: :json

          json = JSON.parse(response.body, symbolize_names: true)
          ids = json[:data].pluck(:id)
          expect(ids).to include(searchable_contact.id.to_s)
        end
      end

      context "when user is a volunteer" do
        let(:volunteer) { create(:volunteer, casa_org: organization) }

        before { sign_in volunteer }

        it "allows access to datatable endpoint" do
          post datatable_case_contacts_new_design_path, params: datatable_params, as: :json

          expect(response).to have_http_status(:success)
        end

        it "only returns case contacts created by the volunteer" do
          volunteer_contact = create(:case_contact, :active, casa_case: casa_case, creator: volunteer)
          other_volunteer_contact = create(:case_contact, :active, casa_case: casa_case,
            creator: create(:volunteer, casa_org: organization))

          post datatable_case_contacts_new_design_path, params: datatable_params, as: :json

          json = JSON.parse(response.body, symbolize_names: true)
          ids = json[:data].pluck(:id)

          expect(ids).to include(volunteer_contact.id.to_s)
          expect(ids).not_to include(other_volunteer_contact.id.to_s)
        end
      end

      context "when user is a supervisor" do
        let(:supervisor) { create(:supervisor, casa_org: organization) }

        before { sign_in supervisor }

        it "allows access to datatable endpoint" do
          post datatable_case_contacts_new_design_path, params: datatable_params, as: :json

          expect(response).to have_http_status(:success)
        end

        it "returns all case contacts in the organization" do
          contact1 = create(:case_contact, :active, casa_case: casa_case,
            creator: create(:volunteer, casa_org: organization))
          contact2 = create(:case_contact, :active, casa_case: casa_case,
            creator: create(:volunteer, casa_org: organization))

          post datatable_case_contacts_new_design_path, params: datatable_params, as: :json

          json = JSON.parse(response.body, symbolize_names: true)
          ids = json[:data].pluck(:id)

          expect(ids).to include(contact1.id.to_s, contact2.id.to_s)
        end
      end

      context "when user is not authenticated" do
        before { sign_out admin }

        it "returns unauthorized status" do
          post datatable_case_contacts_new_design_path, params: datatable_params, as: :json

          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "expanded content fields" do
        let(:contact_topic) { create(:contact_topic, casa_org: organization) }
        let(:case_contact_with_details) do
          create(:case_contact, :active, casa_case: casa_case, notes: "Important follow-up")
        end

        before do
          create(:contact_topic_answer,
            case_contact: case_contact_with_details,
            contact_topic: contact_topic,
            value: "Youth is doing well")
        end

        it "includes contact_topic_answers in the response" do
          post datatable_case_contacts_new_design_path, params: datatable_params, as: :json

          json = JSON.parse(response.body, symbolize_names: true)
          record = json[:data].find { |d| d[:id] == case_contact_with_details.id.to_s }
          expect(record[:contact_topic_answers]).to be_an(Array)
          expect(record[:contact_topic_answers].first[:value]).to eq("Youth is doing well")
        end

        it "includes the topic question in contact_topic_answers" do
          post datatable_case_contacts_new_design_path, params: datatable_params, as: :json

          json = JSON.parse(response.body, symbolize_names: true)
          record = json[:data].find { |d| d[:id] == case_contact_with_details.id.to_s }
          expect(record[:contact_topic_answers].first[:question]).to eq(contact_topic.question)
        end

        it "includes notes in the response" do
          post datatable_case_contacts_new_design_path, params: datatable_params, as: :json

          json = JSON.parse(response.body, symbolize_names: true)
          record = json[:data].find { |d| d[:id] == case_contact_with_details.id.to_s }
          expect(record[:notes]).to eq("Important follow-up")
        end

        it "omits blank topic answer values" do
          create(:contact_topic_answer,
            case_contact: case_contact_with_details,
            contact_topic: contact_topic,
            value: "")

          post datatable_case_contacts_new_design_path, params: datatable_params, as: :json

          json = JSON.parse(response.body, symbolize_names: true)
          record = json[:data].find { |d| d[:id] == case_contact_with_details.id.to_s }
          expect(record[:contact_topic_answers].map { |a| a[:value] }).to all(be_present)
        end

        it "returns a blank value for notes when notes are empty" do
          case_contact_without_notes = create(:case_contact, :active, casa_case: casa_case, notes: "")

          post datatable_case_contacts_new_design_path, params: datatable_params, as: :json

          json = JSON.parse(response.body, symbolize_names: true)
          record = json[:data].find { |d| d[:id] == case_contact_without_notes.id.to_s }
          expect(record[:notes]).to be_blank
        end
      end

      context "contact_topics field" do
        let(:contact_topic) { create(:contact_topic, casa_org: organization) }
        let(:case_contact_with_topics) { create(:case_contact, :active, casa_case: casa_case) }

        before do
          case_contact_with_topics.contact_topics << contact_topic
        end

        it "returns contact_topics as an array of strings" do
          post datatable_case_contacts_new_design_path, params: datatable_params, as: :json

          json = JSON.parse(response.body, symbolize_names: true)
          record = json[:data].find { |d| d[:id] == case_contact_with_topics.id.to_s }
          expect(record[:contact_topics]).to be_an(Array)
        end

        it "includes the topic question in the array" do
          post datatable_case_contacts_new_design_path, params: datatable_params, as: :json

          json = JSON.parse(response.body, symbolize_names: true)
          record = json[:data].find { |d| d[:id] == case_contact_with_topics.id.to_s }
          expect(record[:contact_topics]).to include(contact_topic.question)
        end
      end
    end
  end
end
