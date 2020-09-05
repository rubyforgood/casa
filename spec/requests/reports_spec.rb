require "rails_helper"

RSpec.describe "/reports", type: :request do
  describe "GET #index" do
    subject { get reports_url; response }

    context "while signed in as an admin" do
      before do
        sign_in create(:casa_admin)
      end

      it { is_expected.to be_successful }
    end

    context "while signed in as a supervisor" do
      before do
        sign_in create(:supervisor)
      end

      it { is_expected.to be_successful }
    end

    context "while signed in as a volunteer" do
      before do
        sign_in create(:volunteer)
      end

      it { is_expected.not_to be_successful }
    end
    
  end
end
