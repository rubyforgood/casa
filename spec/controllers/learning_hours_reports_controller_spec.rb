require "rails_helper"

RSpec.describe LearningHoursReportsController, type: :controller do
  let(:admin) { create(:casa_admin) }

  context "without authenctication" do
    describe "#index" do
      before { get :index, as: :csv }

      it "return unauthorized" do
        expect(response).to_not be_successful
      end
    end
  end

  context "as an admin user" do
    before do
      allow(controller).to receive(:authenticate_user!).and_return(true)
      allow(controller).to receive(:current_user).and_return(admin)
    end

    describe "#index" do
      before { get :index, as: :csv }

      it "returns a successful response" do
        expect(response).to be_successful
        expect(response.header["Content-Type"]).to eq("text/csv")
      end
    end
  end
end
