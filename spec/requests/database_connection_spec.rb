require "rails_helper"

# Issue #7401: ActiveRecord::ConnectionNotEstablished ("connection to server ... port 5432 failed:
# Connection refused") means the dyno could not reach Postgres at all -- a DB restart, maintenance
# window or failover. ApplicationController rescues it (and ConnectionTimeoutError) and renders a
# 503, not the generic 500. The Scout error group 71467 traced to GET /case_contacts/:id/form/details,
# so that route is what these specs stub.
RSpec.describe "Database connection failures", type: :request do
  let(:casa_org) { create(:casa_org) }
  let(:supervisor) { create(:supervisor, casa_org:) }
  let(:volunteer) { create(:volunteer, :with_single_case, casa_org:, supervisor:) }
  let(:casa_case) { volunteer.casa_cases.first }
  let(:case_contact) { create(:case_contact, :started_status, casa_case:, creator: volunteer) }

  before { sign_in volunteer }

  describe "GET /case_contacts/:case_contact_id/form/details" do
    def stub_db_failure(error)
      # set_case_contact is the before_action that loads the contact from Postgres; raising here
      # simulates the database being unreachable when the request comes in.
      allow_any_instance_of(CaseContacts::FormController)
        .to receive(:set_case_contact).and_raise(error)
    end

    it "renders the static 503 page (not a 500) when the connection is refused" do
      stub_db_failure ActiveRecord::ConnectionNotEstablished

      get case_contact_form_path(:details, case_contact_id: case_contact.id)

      expect(response).to have_http_status(:service_unavailable)
      expect(response.headers["Retry-After"]).to eq("60")
      expect(response.body).to eq(Rails.public_path.join("503.html").read)
    end

    it "reports the error to Scout, since rescue_from hides it from Scout's middleware" do
      error = ActiveRecord::ConnectionNotEstablished.new("connection refused")
      stub_db_failure error
      allow(ScoutApm::Error).to receive(:capture)

      get case_contact_form_path(:details, case_contact_id: case_contact.id)

      expect(ScoutApm::Error).to have_received(:capture).with(error)
    end

    it "renders the static 503 page when the connection times out" do
      stub_db_failure ActiveRecord::ConnectionTimeoutError

      get case_contact_form_path(:details, case_contact_id: case_contact.id)

      expect(response).to have_http_status(:service_unavailable)
      expect(response.body).to eq(Rails.public_path.join("503.html").read)
    end

    it "renders a JSON error with 503 for JSON (autosave) requests" do
      stub_db_failure ActiveRecord::ConnectionNotEstablished

      get case_contact_form_path(:details, case_contact_id: case_contact.id),
        headers: {"Accept" => "application/json"}

      expect(response).to have_http_status(:service_unavailable)
      expect(response.parsed_body).to eq("error" => ApplicationController::DATABASE_UNAVAILABLE_MESSAGE)
    end
  end
end
