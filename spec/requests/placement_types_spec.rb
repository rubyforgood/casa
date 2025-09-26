require "rails_helper"

RSpec.describe "PlacementTypes", type: :request do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:placement_type) { create(:placement_type, casa_org: organization) }

  describe "as an admin" do
    before do
      sign_in admin
    end

    describe "GET /edit" do
      it "returns http success" do
        get edit_placement_type_path(placement_type)
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /new" do
      it "returns http success" do
        get "/placement_types/new"
        expect(response).to have_http_status(:success)
      end
    end

    describe "POST /create" do
      it "returns http success" do
        expect {
          post "/placement_types", params: {placement_type: {name: "New Placement Type"}}
        }.to change(PlacementType, :count).by(1)
        expect(response).to redirect_to(edit_casa_org_path(organization))
      end
    end

    describe "PATCH /update" do
      it "returns http success" do
        patch placement_type_path(placement_type), params: {placement_type: {name: "Updated Placement Type"}}
        expect(response).to redirect_to(edit_casa_org_path(organization))
        expect(placement_type.reload.name).to eq("Updated Placement Type")
      end
    end
  end
end
