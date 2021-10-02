require "rails_helper"

RSpec.describe "All-Casa Admin" do
  let(:all_casa_admin) { build(:all_casa_admin) }
  let(:casa_admin) { create(:casa_admin, email: "admin1@example.com", display_name: "Example Admin") }
  let(:casa_org) { create(:casa_org) }

  before { sign_in all_casa_admin }

  describe "GET /new" do
    it "allows access to the new admin page" do
      get new_all_casa_admins_casa_org_casa_admin_path(casa_org)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new CASA admin for the organization" do
        expect {
          post all_casa_admins_casa_org_casa_admins_path(casa_org), params: {
            casa_admin: {
              email: "admin1@example.com",
              display_name: "Example Admin"
            }
          }
        }.to change(CasaAdmin, :count).by(1)
      end
    end

    context "with invalid parameters" do
      it "renders new page" do
        post all_casa_admins_casa_org_casa_admins_path(casa_org), params: {
          casa_admin: {
            email: "",
            display_name: ""
          }
        }
        expect(response).to be_successful
        expect(response).to render_template "casa_admins/new"
      end
    end
  end

  describe "PATCH /update" do
    let(:email) { "casa_admin@example.com" }

    context "when current user is all casa admin" do
      it "should allow current user to successfully update other casa admin's email" do
        patch all_casa_admins_casa_org_casa_admin_path(casa_org, casa_admin),
          params: {all_casa_admin: {email: email}}

        expect(response).to redirect_to edit_all_casa_admins_casa_org_casa_admin_path(casa_org, casa_admin)
        expect(flash[:notice]).to eq("New admin created successfully")
        expect(casa_admin.reload.email).to eq(email)
      end

      it "should render edit page if update fails" do
        patch all_casa_admins_casa_org_casa_admin_path(casa_org, casa_admin),
          params: {all_casa_admin: {email: ""}}

        expect(response).to be_successful
        expect(response).to render_template "casa_admins/edit"
      end
    end
  end

  describe "PATCH /deactivate" do
    context "when current user is all casa admin" do
      it "should successfully deactivate another casa admin's profile" do
        casa_admin.update(active: true)
        patch deactivate_all_casa_admins_casa_org_casa_admin_path(casa_org, casa_admin)

        expect(response).to redirect_to edit_all_casa_admins_casa_org_casa_admin_path(casa_org, casa_admin)
        expect(flash[:notice]).to eq("Admin was deactivated.")
        expect(casa_admin.reload.active).to eq(false)
      end

      it "should render edit page if update fails" do
        allow_any_instance_of(CasaAdmin).to receive(:deactivate).and_return(false)
        patch deactivate_all_casa_admins_casa_org_casa_admin_path(casa_org, casa_admin)

        expect(response).to be_successful
        expect(response).to render_template "casa_admins/edit"
      end
    end
  end

  describe "PATCH /activate" do
    context "when current user is all casa admin" do
      it "should successfully activate another casa admin's profile" do
        casa_admin.update(active: false)
        patch activate_all_casa_admins_casa_org_casa_admin_path(casa_org, casa_admin)

        expect(response).to redirect_to edit_all_casa_admins_casa_org_casa_admin_path(casa_org, casa_admin)
        expect(flash[:notice]).to eq("Admin was activated. They have been sent an email.")
        expect(casa_admin.reload.active).to eq(true)
      end

      it "should render edit page if update fails" do
        allow_any_instance_of(CasaAdmin).to receive(:activate).and_return(false)
        patch activate_all_casa_admins_casa_org_casa_admin_path(casa_org, casa_admin)

        expect(response).to be_successful
        expect(response).to render_template "casa_admins/edit"
      end
    end
  end

  describe ".edit" do
    let(:other_admin) { create(:casa_admin, email: "other_admin@example.com", display_name: "Other Admin") }

    context "when user is all casa admin" do
      it "should allow access to the edit admin page" do
        get edit_all_casa_admins_casa_org_casa_admin_path(casa_org, casa_admin)
        expect(response).to be_successful
      end
    end

    context "when not logged in" do
      it "should not allow access to edit admin page" do
        sign_out all_casa_admin

        get edit_all_casa_admins_casa_org_casa_admin_path(casa_org, casa_admin)
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when user does not have all casa admin permissions" do
      it "should not allow access to edit admin page" do
        sign_out all_casa_admin
        sign_in other_admin

        get edit_all_casa_admins_casa_org_casa_admin_path(casa_org, casa_admin)

        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
