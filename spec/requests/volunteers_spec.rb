require "rails_helper"

RSpec.describe "/volunteers", type: :request do
  let(:admin) { create(:casa_admin) }
  let(:volunteer) { create(:volunteer) }

  describe "GET /index" do
    it "renders a successful response" do
      sign_in volunteer

      get "/"

      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "render a successful response" do
      sign_in admin

      get edit_volunteer_url(volunteer)

      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    it "creates a new user" do
      expected_email = "volunteer1@example.com"
      sign_in admin

      post volunteers_url, params: {
        volunteer: {email: expected_email, casa_org_id: admin.casa_org_id}
      }

      expect(User.last.email).to eq(expected_email)

      expect(response).to redirect_to root_path
    end

    it "sends an account_setup email" do
      expected_email = "volunteer1@example.com"
      sign_in admin

      expect {
        post volunteers_url, params: {
          volunteer: {email: expected_email, casa_org_id: admin.casa_org_id}
        }
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe "PATCH /update" do
    it "updates the volunteer" do
      sign_in admin

      patch volunteer_path(volunteer), params: update_volunteer_params
      volunteer.reload

      expect(volunteer.display_name).to eq "New Name"
      expect(volunteer.email).to eq "newemail@gmail.com"
      expect(volunteer.role).to eq "inactive"
    end
  end

  def update_volunteer_params
    {volunteer: {email: "newemail@gmail.com", display_name: "New Name", role: "inactive"}}
  end
end
