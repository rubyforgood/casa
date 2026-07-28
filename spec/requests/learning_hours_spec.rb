require "rails_helper"

RSpec.describe "LearningHours", type: :request do
  let(:volunteer) { create(:volunteer) }

  shared_examples "test request with user" do |factory|
    let(:user) { create(factory) }

    before { sign_in user }

    describe "GET /index" do
      it "succeeds" do
        get learning_hours_path
        expect(response).to have_http_status(:success)
      end

      it "displays the time completed column" do
        get learning_hours_path
        expect(response.body).to include("Time Completed YTD")
      end
    end
  end

  context "as a volunteer user" do
    before { sign_in volunteer }

    describe "GET /index" do
      it "succeeds" do
        get learning_hours_path
        expect(response).to have_http_status(:success)
      end

      it "displays the Learning Topic column if learning_topic_active is true" do
        volunteer.casa_org.update(learning_topic_active: true)
        get learning_hours_path
        expect(response.body).to include("Learning Topic")
      end

      it "does not display the Learning Topic column if learning_topic_active is false" do
        volunteer.casa_org.update(learning_topic_active: false)
        get learning_hours_path
        expect(response.body).not_to include("Learning Topic")
      end
    end
  end

  context "as a supervisor user" do
    include_examples "test request with user", :supervisor
  end

  context "as an admin user" do
    include_examples "test request with user", :casa_admin
  end
end
