require "rails_helper"

RSpec.describe "Placements", type: :request do
  let(:casa_org) { build(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org:) }
  let(:casa_case) { create(:casa_case, casa_org:) }

  before do
    sign_in admin
  end

  describe "GET /index" do
    it "displays the placement information" do
      get casa_case_placements_path(casa_case)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Placement History")
      expect(response.body).to include(casa_case.case_number)
    end
  end

  describe "GET /show" do
    it "displays the placement details" do
      placement_type = build(:placement_type, casa_org:, name: "Reunification")
      placement = create(:placement, casa_case:, placement_type:)

      get casa_case_placement_path(casa_case, placement)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Placement")
      expect(response.body).to include("Reunification")
      expect(response.body).to include(casa_case.case_number)
    end
  end

  describe "GET /new" do
    it "returns a successful response" do
      get new_casa_case_placement_path(casa_case)

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns a successful response" do
      placement = create(:placement, casa_case:)

      get edit_casa_case_placement_path(casa_case, placement)

      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    context "when the params are valid" do
      it "creates the placement successfully and redirects to the placement" do
        placement_type = create(:placement_type, casa_org:, name: "Adoption by relative")

        params = {
          placement: {
            placement_started_at: Date.new(2026, 2, 1),
            placement_type_id: placement_type.id
          }
        }

        expect do
          post casa_case_placements_path(casa_case), params: params
        end.to change(Placement, :count).by(1)

        expect(response).to have_http_status(:redirect)
        expect(flash[:notice]).to match(/placement was successfully created/i)
        follow_redirect!
        expect(response.body).to include("Placement")
        expect(response.body).to include("Adoption by relative")
        expect(response.body).to include(casa_case.case_number)
      end
    end
  end

  describe "PATCH /update" do
    context "when the params are valid" do
      it "updates the placement successfully" do
        placement = create(:placement, casa_case:, placement_started_at: Date.new(2026, 4, 1))

        params = {placement: {placement_started_at: Date.new(2026, 1, 1)}}
        patch casa_case_placement_path(casa_case, placement), params: params

        expect(response).to redirect_to(casa_case_placements_path(casa_case))
        expect(placement.reload.placement_started_at).to eq(Date.new(2026, 1, 1))
        expect(flash[:notice]).to match(/placement was successfully updated/i)
      end
    end

    context "when the params are invalid" do
      it "returns an unprocessable_content response" do
        placement = create(:placement, casa_case:, placement_started_at: Date.new(2026, 4, 1))

        params = {placement: {placement_started_at: 1000.years.ago}}
        patch casa_case_placement_path(casa_case, placement), params: params

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    it "deletes the placement successfully" do
      placement = create(:placement, casa_case:)

      expect do
        delete casa_case_placement_path(casa_case, placement)
      end.to change(Placement, :count).by(-1)

      expect(response).to have_http_status(:redirect)
      expect(flash[:notice]).to match(/placement was successfully deleted/i)
      follow_redirect!
      expect(response.body).to include("Placement History")
      expect(response.body).to include(casa_case.case_number)
    end
  end
end
