require 'rails_helper'

RSpec.describe "CasaOrgs", type: :request do
  let(:organization) { create(:casa_org) }
  let(:valid_attributes) { {case_number: "1234", transition_aged_youth: true, casa_org_id: organization.id} }
  let(:invalid_attributes) { {case_number: nil} }
  let(:casa_case) { create(:casa_case, casa_org: organization) }

  describe "as an admin" do
    before { sign_in create(:casa_admin, casa_org: organization) }
    describe "GET /edit" do
      it "render a successful response" do
        get edit_casa_org_url(organization)
        expect(response).to be_successful
      end
    end

  end
end
