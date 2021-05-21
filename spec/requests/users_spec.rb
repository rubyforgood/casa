require "rails_helper"

RSpec.describe "/users", :disable_bullet, type: :request do
  describe "GET /edit" do
    context "with a volunteer signed in" do
      it "renders a successful response" do
        sign_in create(:volunteer)

        get edit_users_path

        expect(response).to be_successful
      end
    end

    context "with an admin signed in" do
      it "renders a successful response" do
        sign_in create(:casa_admin)

        get edit_users_path

        expect(response).to be_successful
      end
    end
  end

  describe "PATCH /update" do
    it "updates the user" do
      volunteer = create(:volunteer)
      sign_in volunteer

      patch users_path, params: {user: {display_name: "New Name"}}

      expect(volunteer.display_name).to eq "New Name"
    end
  end
end
