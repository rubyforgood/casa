require "rails_helper"

RSpec.describe "/case_court_orders", type: :request do
  subject(:delete_request) { delete case_court_order_url(case_court_order) }
  let(:case_court_order) { build(:case_court_order) }

  before do
    sign_in user
    casa_case = create(:casa_case)
    casa_case.case_court_orders << case_court_order
  end

  describe "as an admin" do
    let(:user) { build(:casa_admin) }

    describe "DELETE /destroy" do
      it "renders a successful response" do
        delete_request
        expect(response).to be_successful
      end

      it "deletes the court order" do
        expect { delete_request }.to change(CaseCourtOrder, :count).from(1).to(0)
      end
    end
  end

  describe "as a supervisor" do
    let(:user) { build(:supervisor) }

    describe "DELETE /destroy" do
      it "renders a successful response" do
        delete_request
        expect(response).to be_successful
      end

      it "deletes the court order" do
        expect { delete_request }.to change(CaseCourtOrder, :count).from(1).to(0)
      end
    end
  end

  describe "as a volunteer" do
    let(:user) { build(:volunteer) }

    describe "DELETE /destroy" do
      it "renders a successful response" do
        delete_request
        expect(response).to be_successful
      end

      it "deletes the court order" do
        expect { delete_request }.to change(CaseCourtOrder, :count).from(1).to(0)
      end
    end
  end
end
