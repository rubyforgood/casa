require "rails_helper"

RSpec.describe "AllCasaAdmin::CasaOrgs", type: :request do
  let(:all_casa_admin) { create(:all_casa_admin) }

  before { sign_in all_casa_admin }

  describe "GET /show" do
    let!(:casa_org) { create(:casa_org) }
    let!(:other_casa_org) { create(:casa_org) }

    subject(:request) do
      get all_casa_admins_casa_org_path(casa_org)

      response
    end

    it { is_expected.to be_successful }

    it "shows casa org correctly", :aggregate_failures do
      page = request.body
      expect(page).to include(casa_org.name)
      expect(page).not_to include(other_casa_org.name)
    end

    it "load metrics correctly" do
      expect(AllCasaAdmins::CasaOrgMetrics).to receive(:new).with(casa_org).and_call_original
      request
    end
  end

  describe "GET /new" do
    subject(:get_new) { get new_all_casa_admins_casa_org_path }

    it "returns http success" do
      get_new

      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    subject(:post_create) { post all_casa_admins_casa_orgs_path, params: params }

    context "when successfully" do
      let(:params) do
        {casa_org: {name: "New Org", display_name: "New org display",
                    address: "29207 Weimann Canyon, New Andrew, PA 40510-7416"}}
      end
      let(:contact_topics) { [{"question" => "Title 1", "details" => "details 1"}, {"question" => "Title 2", "details" => "details 2"}] }

      before do
        allow(ContactTopic).to receive(:default_contact_topics).and_return(contact_topics)
      end

      it "creates a new CASA org" do
        expect { post_create }.to change(CasaOrg, :count).by(1)
      end

      it "generates correct defaults during creation" do
        expect { post_create }.to change(ContactTopic, :count).by(2)

        casa_org = CasaOrg.last
        expect(casa_org.contact_topics.map(&:question)).to eq contact_topics.map { |t| t["question"] }
        expect(casa_org.contact_topics.map(&:details)).to eq contact_topics.map { |t| t["details"] }
        expect(casa_org.contact_topics.pluck(:active)).to be_all true
      end

      it "redirects to CASA org show page, with notice flash", :aggregate_failures do
        post_create

        expect(response).to redirect_to all_casa_admins_casa_org_path(assigns(:casa_org))
        expect(flash[:notice]).to eq "CASA Organization was successfully created."
      end

      it "also responds as json", :aggregate_failures do
        post all_casa_admins_casa_orgs_path(format: :json), params: params

        expect(response.content_type).to eq "application/json; charset=utf-8"
        expect(response).to have_http_status :created
        expect(response.body).to match "29207 Weimann Canyon, New Andrew, PA 40510-7416"
      end
    end

    context "when failure" do
      let(:params) do
        {casa_org: {name: nil, display_name: nil,
                    address: "29207 Weimann Canyon, New Andrew, PA 40510-7416"}}
      end

      it "does not create a new CASA org" do
        expect { post_create }.not_to change(CasaOrg, :count)
      end

      it "renders new template" do
        post_create

        expect(response).to render_template :new
      end

      it "also responds as json", :aggregate_failures do
        post all_casa_admins_casa_orgs_path(format: :json), params: params

        expect(response.content_type).to eq "application/json; charset=utf-8"
        expect(response).to have_http_status :unprocessable_entity
        expect(response.body).to match "Name can't be blank"
      end
    end
  end
end
