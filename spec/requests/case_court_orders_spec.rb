require "rails_helper"

RSpec.describe "/case_court_orders", type: :request do
  let(:user) { build(:casa_admin) }
  let(:case_court_order) { build(:case_court_order) }

  before do
    sign_in user
    casa_case = create(:casa_case)
    casa_case.case_court_orders << case_court_order
  end

  describe "DELETE /destroy" do
    subject(:request) do
      delete case_court_order_url(case_court_order)

      response
    end

    it { is_expected.to be_successful }

    it "deletes the court order" do
      expect { request }.to change(CaseCourtOrder, :count).from(1).to(0)
    end
  end
end
