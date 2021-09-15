require "rails_helper"

RSpec.describe "/case_court_mandates", type: :request do
  subject(:delete_request) { delete case_court_mandate_url(case_court_mandate) }
  let(:case_court_mandate) { build(:case_court_mandate) }

  before do
    sign_in user
    casa_case = create(:casa_case)
    casa_case.case_court_mandates << case_court_mandate
  end

  describe "as an admin" do
    let(:user) { build(:casa_admin) }

    describe "DELETE /destroy" do
      it "renders a successful response" do
        delete_request
        expect(response).to be_successful
      end

      it "deletes the court mandate" do
        expect { delete_request }.to change(CaseCourtMandate, :count).from(1).to(0)
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

      it "deletes the court mandate" do
        expect { delete_request }.to change(CaseCourtMandate, :count).from(1).to(0)
      end
    end
  end

  describe "as a volunteer" do
    let(:user) { build(:volunteer) }

    describe "DELETE /destroy" do
      it "renders a successful response" do
        delete_request
        # CASA will attempt to redirect to another page
        expect(response.status).to be(302)
      end

      it "deletes the court mandate" do
        expect { delete_request }.to_not change(CaseCourtMandate, :count)
      end
    end
  end
end
