require "rails_helper"

RSpec.describe "LearningHours", type: :request do
  let(:volunteer) { create(:volunteer) }

  context "as a volunteer user" do
    before { sign_in volunteer }

    describe "GET /index" do
      it "succeeds" do
        get volunteer_learning_hours_path(volunteer_id: volunteer.id)
        expect(response).to have_http_status(:success)
      end
    end
  end
end
