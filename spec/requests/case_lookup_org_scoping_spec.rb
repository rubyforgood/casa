require "rails_helper"

RSpec.describe "Case lookups are scoped to the current organization", type: :request do
  let(:casa_org) { create(:casa_org) }
  let(:other_org) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: casa_org) }
  # The other org's case is created first so an unscoped lookup would return it.
  let!(:other_case) { create(:casa_case, casa_org: other_org, case_number: "CINA-21-1234") }
  let!(:own_case) { create(:casa_case, casa_org: casa_org, case_number: "CINA-21-1234") }

  before { sign_in admin }

  describe "PATCH /casa_cases/:id/copy_court_orders" do
    let!(:other_order) { create(:case_court_order, casa_case: other_case) }
    let!(:own_order) { create(:case_court_order, casa_case: create(:casa_case, casa_org: casa_org, case_number: "CINA-22-0001")) }

    it "copies the court orders of the case with that number in the caller's org" do
      expect {
        patch copy_court_orders_casa_case_path(own_case), params: {case_number_cp: "CINA-22-0001"}, as: :js
      }.to change { own_case.case_court_orders.count }.by(1)
    end

    it "does not copy court orders from another org's case" do
      only_elsewhere = create(:casa_case, casa_org: other_org, case_number: "CINA-23-9999")
      create(:case_court_order, casa_case: only_elsewhere)

      patch copy_court_orders_casa_case_path(own_case), params: {case_number_cp: only_elsewhere.case_number}, as: :js

      expect(response).to have_http_status(:not_found)
      expect(own_case.case_court_orders).to be_empty
    end
  end

  describe "GET /casa_cases/:casa_case_id/fund_request/new" do
    it "resolves the case number to the caller's own case" do
      get new_casa_case_fund_request_path(own_case.slug)

      expect(response).to have_http_status(:ok)
    end

    it "redirects to root for a case that exists only in another org" do
      only_elsewhere = create(:casa_case, casa_org: other_org, case_number: "CINA-30-0001")

      get new_casa_case_fund_request_path(only_elsewhere.slug)

      expect(response).to redirect_to(root_path)
    end
  end

  describe "emancipations" do
    it "shows the checklist of the caller's own case when another org shares the case number" do
      get casa_case_emancipation_path(own_case.slug)

      expect(response).to have_http_status(:ok)
    end

    it "answers not found when saving for a case that exists only in another org" do
      only_elsewhere = create(:casa_case, casa_org: other_org, case_number: "CINA-30-0002")

      post save_casa_case_emancipation_path(only_elsewhere.slug), params: {check_item_action: "add_category"}

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /case_assignments" do
    let(:volunteer) { create(:volunteer, casa_org: casa_org) }

    it "assigns the volunteer to the caller's own case when another org shares the case number" do
      post case_assignments_path(casa_case_id: own_case.slug), params: {case_assignment: {volunteer_id: volunteer.id}}

      expect(own_case.reload.case_assignments.map(&:volunteer_id)).to eq([volunteer.id])
      expect(other_case.reload.case_assignments).to be_empty
    end
  end

  describe "PATCH /volunteers/:id/activate" do
    let(:volunteer) { create(:volunteer, :inactive, casa_org: casa_org) }

    it "answers not found without activating or emailing when the redirect case exists only in another org" do
      only_elsewhere = create(:casa_case, casa_org: other_org, case_number: "CINA-30-0003")

      expect {
        patch activate_volunteer_path(volunteer), params: {redirect_to_path: "casa_case", casa_case_id: only_elsewhere.slug}
      }.not_to change { ActionMailer::Base.deliveries.count }

      expect(response).to have_http_status(:not_found)
      expect(volunteer.reload).not_to be_active
    end

    it "redirects to the caller's own case when another org shares the case number" do
      patch activate_volunteer_path(volunteer), params: {redirect_to_path: "casa_case", casa_case_id: own_case.slug}

      expect(response).to redirect_to(edit_casa_case_path(own_case))
      expect(volunteer.reload).to be_active
    end
  end
end
