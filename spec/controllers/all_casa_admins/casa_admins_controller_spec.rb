require "rails_helper"

RSpec.describe AllCasaAdmins::CasaAdminsController, type: :controller do
  let(:all_casa_admin) { create(:all_casa_admin) }
  let(:casa_org) { create(:casa_org) }

  before do
    sign_in all_casa_admin
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

    it "should authenticate the user" do
      sign_out all_casa_admin
      casa_admin = create(:casa_admin)
      get :edit, params: {
        id: casa_admin.id,
        casa_org_id: casa_org.id
      }
      expect(response).to have_http_status(:redirect)
    end

    it "should only allow all casa admin users" do
      sign_out all_casa_admin
      other_admin = create(:casa_admin, email: "other_admin@example.com", display_name: "Other Admin")
      sign_in other_admin
      casa_admin = create(:casa_admin)
      get :edit, params: {
        id: casa_admin.id,
        casa_org_id: casa_org.id
      }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "PATCH update" do
    it "should update casa admins", :aggregate_failures do
      casa_admin = create(:casa_admin)
      patch :update, params: {
        casa_org_id: casa_org.id,
        id: casa_admin.id,
        all_casa_admin: {
          email: "updated_admin1@example.com"
        }
      }
      expect(response).to have_http_status(:found)
      expect(flash[:notice]).to eq("New admin created successfully")
      casa_admin.reload
      expect(casa_admin.email).to eq "updated_admin1@example.com"
    end

    it "renders the edit page for invalid inputs" do
      casa_admin = create(:casa_admin)
      patch :update, params: {
        casa_org_id: casa_org.id,
        id: casa_admin.id,
        all_casa_admin: {
          email: ""
        }
      }
      expect(response).to render_template "casa_admins/edit"
    end
  end

  describe "PATCH activate" do
    it "should activate a casa admin user", :aggregate_failures do
      casa_admin = create(:casa_admin)
      casa_admin.update(active: false)
      patch :activate, params: {
        casa_org_id: casa_org.id,
        id: casa_admin.id
      }
      expect(response).to have_http_status(:found)
      expect(flash[:notice]).to eq("Admin was activated. They have been sent an email.")
      expect(casa_admin.reload.active).to eq(true)
    end

    it "renders the edit page if the activate process fails" do
      allow_any_instance_of(CasaAdmin).to receive(:activate).and_return(false)
      casa_admin = create(:casa_admin)
      patch :activate, params: {
        casa_org_id: casa_org.id,
        id: casa_admin.id
      }
      expect(response).to render_template "casa_admins/edit"
    end
  end

  describe "PATCH deactivate" do
    it "should deactivate a casa admin user", :aggregate_failures do
      casa_admin = create(:casa_admin)
      casa_admin.update(active: true)
      patch :deactivate, params: {
        casa_org_id: casa_org.id,
        id: casa_admin.id
      }
      expect(response).to have_http_status(:found)
      expect(flash[:notice]).to eq("Admin was deactivated.")
      expect(casa_admin.reload.active).to eq(false)
    end

    it "renders the edit page if the deactivate process fails" do
      allow_any_instance_of(CasaAdmin).to receive(:deactivate).and_return(false)
      casa_admin = create(:casa_admin)
      patch :deactivate, params: {
        casa_org_id: casa_org.id,
        id: casa_admin.id
      }
      expect(response).to render_template "casa_admins/edit"
    end
  end
end
