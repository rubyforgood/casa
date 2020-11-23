require "rails_helper"

RSpec.describe "/volunteers", type: :request do
  let(:admin) { create(:casa_admin) }
  let(:volunteer) { create(:volunteer) }

  describe "GET /index" do
    it "renders a successful response" do
      sign_in admin

      get volunteers_path
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response only for admin user" do
      sign_in admin

      get new_volunteer_path
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
    before do
      sign_in admin
    end

    context "with valid params" do
      let(:params) do
        {
          volunteer: {
            display_name: "Example",
            email: "volunteer1@example.com",
            casa_org_id: admin.casa_org_id
          }
        }
      end

      it "creates a new volunteer" do
        post volunteers_url, params: params
        expect(response).to have_http_status(:redirect)
        volunteer = Volunteer.last
        expect(volunteer.email).to eq("volunteer1@example.com")
        expect(volunteer.display_name).to eq("Example")
        expect(response).to redirect_to volunteers_path
      end

      it "sends an account_setup email" do
        expect {
          post volunteers_url, params: params
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context "with invalid parameters" do
      let(:params) do
        {
          volunteer: {
            display_name: "",
            email: "volunteer1@example.com",
            casa_org_id: admin.casa_org_id
          }
        }
      end

      it "does not create a new volunteer" do
        expect {
          post volunteers_url, params: params
        }.to_not change { Volunteer.count }
        expect(response).to have_http_status(:success)
      end

      it "sends an account_setup email" do
        expect {
          post volunteers_url, params: params
        }.to_not change { ActionMailer::Base.deliveries.count }
      end
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
