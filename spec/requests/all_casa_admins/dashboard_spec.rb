require "rails_helper"

RSpec.describe "AllCasaAdmin::Dashboard", type: :request do
  let(:all_casa_admin) { create(:all_casa_admin) }

  before { sign_in all_casa_admin }

  describe "GET /show" do
    let!(:casa_orgs) { create_list(:casa_org, 3) }

    subject(:request) do
      get authenticated_all_casa_admin_root_path

      response
    end

    it { is_expected.to have_http_status(:success) }

    it "shows casa orgs" do
      page = request.parsed_body
      expect(page).to include(*casa_orgs.map(&:name))
    end
  end
end
