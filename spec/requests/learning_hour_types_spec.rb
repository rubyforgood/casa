require "rails_helper"

RSpec.describe "LearningHourTypes", type: :request do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:volunteer) { create(:volunteer, casa_org: organization) }

  describe "GET /new" do
    context "as an admin" do
      before { sign_in admin }

      it "renders successfully" do
        get new_learning_hour_type_path
        expect(response).to have_http_status(:success)
      end
    end

    context "as a volunteer" do
      before { sign_in volunteer }

      it "redirects to root as not authorized" do
        get new_learning_hour_type_path

        expect(response).to redirect_to(root_url)
        expect(flash[:notice]).to eq("Sorry, you are not authorized to perform this action.")
      end
    end
  end

  describe "POST /create" do
    before { sign_in admin }

    context "with valid params" do
      let(:params) { {learning_hour_type: {name: "New Type", active: true}} }

      it "creates a learning hour type and redirects" do
        expect {
          post learning_hour_types_path, params: params
        }.to change(LearningHourType, :count).by(1)

        expect(response).to redirect_to(edit_casa_org_path(organization))
        follow_redirect!
        expect(response.body).to include("Learning Type was successfully created.")
      end
    end

    context "with invalid params" do
      let(:params) { {learning_hour_type: {name: ""}} }

      it "does not create a type and renders new" do
        expect {
          post learning_hour_types_path, params: params
        }.not_to change(LearningHourType, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /edit" do
    let(:learning_hour_type) { create(:learning_hour_type, casa_org: organization) }

    context "as an admin" do
      before { sign_in admin }

      it "renders successfully" do
        get edit_learning_hour_type_path(learning_hour_type)
        expect(response).to have_http_status(:success)
      end
    end

    context "as a volunteer" do
      before { sign_in volunteer }

      it "redirects to root as not authorized" do
        get edit_learning_hour_type_path(learning_hour_type)

        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe "PATCH /update" do
    let(:learning_hour_type) { create(:learning_hour_type, casa_org: organization, name: "Old Name") }

    before { sign_in admin }

    context "with valid params" do
      it "updates the type and redirects" do
        patch learning_hour_type_path(learning_hour_type), params: {learning_hour_type: {name: "Updated Name"}}

        expect(response).to redirect_to(edit_casa_org_path(organization))
        expect(learning_hour_type.reload.name).to eq("Updated Name")
      end
    end

    context "with invalid params" do
      it "does not update and renders edit" do
        patch learning_hour_type_path(learning_hour_type), params: {learning_hour_type: {name: ""}}

        expect(response).to have_http_status(:unprocessable_content)
        expect(learning_hour_type.reload.name).to eq("Old Name")
      end
    end
  end
end
