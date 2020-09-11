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
    it "creates a new volunteer" do
      expected_email = "volunteer1@example.com"
      sign_in admin

      post volunteers_url, params: {
        volunteer: {email: expected_email, casa_org_id: admin.casa_org_id}
      }

      volunteer = Volunteer.last
      expect(volunteer.email).to eq(expected_email)

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
    before { sign_in admin }

    context "with valid params" do
      it "updates the volunteer" do
        patch volunteer_path(volunteer), params: {
          volunteer: {email: "newemail@gmail.com", display_name: "New Name"}
        }
        expect(response).to have_http_status(:redirect)

        volunteer.reload
        expect(volunteer.display_name).to eq "New Name"
        expect(volunteer.email).to eq "newemail@gmail.com"
      end
    end

    context "with invalid params" do
      let!(:other_volunteer) { create(:volunteer) }

      it "does not update the volunteer" do
        patch volunteer_path(volunteer), params: {
          volunteer: {email: other_volunteer.email, display_name: "New Name"}
        }
        expect(response).to have_http_status(:success) # Re-renders form

        volunteer.reload
        expect(volunteer.display_name).to_not eq "New Name"
        expect(volunteer.email).to_not eq other_volunteer.email
      end
    end

    # Activation/deactivation must be done separately through /activate and
    # /deactivate, respectively
    it "cannot change the active state" do
      patch volunteer_path(volunteer), params: {
        volunteer: {active: false}
      }
      volunteer.reload

      expect(volunteer.active).to eq(true)
    end
  end

  describe "PATCH /activate" do
    let(:volunteer) { create(:volunteer, :inactive) }

    it "activates an inactive volunteer" do
      sign_in admin

      patch activate_volunteer_path(volunteer)

      volunteer.reload
      expect(volunteer.active).to eq(true)
    end

    it "sends an activation email" do
      sign_in admin

      expect {
        patch activate_volunteer_path(volunteer)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe "PATCH /deactivate" do
    it "deactivates an active volunteer" do
      sign_in admin

      patch deactivate_volunteer_path(volunteer)

      volunteer.reload
      expect(volunteer.active).to eq(false)
    end

    it "sends an activation email" do
      sign_in admin

      expect {
        patch deactivate_volunteer_path(volunteer)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
