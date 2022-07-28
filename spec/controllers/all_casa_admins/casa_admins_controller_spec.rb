require "rails_helper"

RSpec.describe AllCasaAdmins::CasaAdminsController, type: :controller do
  let(:all_casa_admin) { build(:all_casa_admin) }
  let(:casa_org) { create(:casa_org) }

  before do
    all_casa_admin.update_attribute(:id, 5)
    sign_in all_casa_admin
  end

  describe "GET new" do
    it "should load the page" do
      get :new, params: { casa_org_id: casa_org.id }
      expect(response).to be_successful
    end
  end

  describe "POST create" do
    it "should create a casa admin", :aggregate_failures do
      expect {
        post :create, params: {
          casa_org_id: casa_org.id,
          casa_admin: {
            email: "admin1@example.com",
            display_name: "Example Admin"
          }
        }
      }.to change(CasaAdmin, :count).by(1)
      expect(response).to have_http_status(:found)
    end

    it "doesn't allow blank attributes" do
      expect {
        post :create, params: {
          casa_org_id: casa_org.id,
          casa_admin: {
            email: "",
            display_name: ""
          }
        }
      }.not_to change(CasaAdmin, :count)
      expect(response).to render_template "casa_admins/new"
    end
  end

  describe "GET edit" do
    it "should load the page" do
      casa_admin = create(:casa_admin)
      get :edit, params: {
        id: casa_admin.id,
        casa_org_id: casa_org.id
      }
      expect(response).to be_successful
    end
  end

  # describe "PATCH update" do
  #   it "should update casa admins", :aggregate_failures do
  #     casa_admin = create(:casa_admin)
  #     patch :update, params: {
  #       casa_org_id: casa_org.id,
  #       id: casa_admin.id,
  #       casa_admin: {
  #         email: "new_admin1@example.com",
  #         display_name: "New Example Admin Name"
  #       }
  #     }
  #     expect(response).to have_http_status(:success)
  #     casa_admin.reload
  #     expect(casa_admin.email).to eq "new_admin1@example.com"
  #     expect(casa_admin.display_name).to eq "New Example Admin Name"
  #   end
  # end
end
