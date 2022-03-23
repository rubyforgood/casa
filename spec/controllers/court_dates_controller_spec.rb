require "rails_helper"

RSpec.describe CourtDatesController, type: :controller do
  let(:organization) { create(:casa_org) }
  let(:volunteer) { create(:volunteer, :with_casa_cases, casa_org: organization) }
  let(:admin) { create(:casa_admin) }
  let(:supervisor) { create(:supervisor) }
  let!(:casa_case) { create(:casa_case, casa_org: organization) }
  let!(:court_date) { create(:court_date, :with_court_details, casa_case: casa_case, date: Date.current + 1.week) }

  describe "DELETE destroy" do
    context "when logged in as admin" do
      before do
        allow(controller).to receive(:authenticate_user!).and_return(true)
        allow(controller).to receive(:current_user).and_return(admin)
        request.env["HTTP_REFERER"] = "/"
      end

      context ".destroy" do
        before { delete :destroy, params: {casa_case_id: casa_case.id, id: court_date.id} }
        it { expect(response).to have_http_status(:redirect) }
        it { expect(flash[:notice]).to eq("Court date was successfully deleted.") }
      end
    end

    context "when logged in as supervisor" do
      before do
        allow(controller).to receive(:authenticate_user!).and_return(true)
        allow(controller).to receive(:current_user).and_return(supervisor)
        request.env["HTTP_REFERER"] = "/"
      end

      context ".destroy" do
        before { delete :destroy, params: {casa_case_id: casa_case.id, id: court_date.id} }
        it { expect(response).to have_http_status(:redirect) }
        it { expect(flash[:notice]).to eq("Court date was successfully deleted.") }
      end
    end

    context "when logged in as volunteer" do
      before do
        allow(controller).to receive(:authenticate_user!).and_return(true)
        allow(controller).to receive(:current_user).and_return(volunteer)
        request.env["HTTP_REFERER"] = "/"
      end

      context ".destroy" do
        before { delete :destroy, params: {casa_case_id: casa_case.id, id: court_date.id} }
        it { expect(response).to have_http_status(:redirect) }
        it { expect(flash[:notice]).to eq("Sorry, you are not authorized to perform this action.") }
      end
    end
  end
end
