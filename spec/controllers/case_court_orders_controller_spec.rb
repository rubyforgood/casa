require "rails_helper"

RSpec.describe CaseCourtOrdersController, type: :controller do
  let(:case_court_order) { create(:case_court_order) }

  before do
    casa_case = create(:casa_case)
    casa_case.case_court_orders << case_court_order
  end

  describe "DELETE destroy" do
    context "when admin" do
      let(:user) { create(:casa_admin) }

      before do
        sign_in user
      end

      it "renders a successful response" do
        delete :destroy, params: {id: case_court_order.id}
        expect(response).to be_successful
      end

      it "deletes the court order" do
        expect { delete :destroy, params: {id: case_court_order.id} }.to change(CaseCourtOrder, :count).from(1).to(0)
      end
    end

    context "when supervisor" do
      let(:user) { create(:supervisor) }

      before do
        sign_in user
      end

      it "renders a successful response" do
        delete :destroy, params: {id: case_court_order.id}
        expect(response).to be_successful
      end

      it "deletes the court order" do
        expect { delete :destroy, params: {id: case_court_order.id} }.to change(CaseCourtOrder, :count).from(1).to(0)
      end
    end

    context "when volunteer" do
      let(:user) { create(:volunteer) }

      before do
        sign_in user
      end

      it "renders a successful response" do
        delete :destroy, params: {id: case_court_order.id}
        expect(response).to be_successful
      end

      it "deletes the court order" do
        expect { delete :destroy, params: {id: case_court_order.id} }.to change(CaseCourtOrder, :count).from(1).to(0)
      end
    end
  end
end
