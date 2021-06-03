require "rails_helper"

RSpec.describe "/casa_cases/:casa_case_id/past_court_dates/:id", :disable_bullet, type: :request do
  describe "GET /show" do
    subject(:show) { get casa_case_past_court_date_path(casa_case, past_court_date) }

    let(:casa_case) { past_court_date.casa_case }
    let(:past_court_date) { create(:past_court_date) }

    context "when the request is authenticated" do
      before do
        sign_in_as_admin
        show
      end

      it { expect(response).to have_http_status(:success) }
    end

    context "when the request is unauthenticated" do
      before { show }

      it { expect(response).to redirect_to new_user_session_path }
    end

    context "when request format is word document" do
      subject(:show) { get casa_case_past_court_date_path(casa_case, past_court_date), headers: headers }

      let(:headers) { {accept: "application/vnd.openxmlformats-officedocument.wordprocessingml.document"} }

      before do
        sign_in_as_admin
        show
      end

      it { expect(response).to be_successful }
    end
  end
end
