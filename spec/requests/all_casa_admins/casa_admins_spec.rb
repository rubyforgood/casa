require "rails_helper"

RSpec.describe "All-Casa Admin" do
  let(:all_casa_admin) { build(:all_casa_admin) }
  let(:casa_admin) { create(:casa_admin, email: "admin1@example.com", display_name: "Example Admin") }
  let(:casa_org) { create(:casa_org) }

  before {
    sign_in all_casa_admin
    expect_any_instance_of(AllCasaAdmins::CasaAdminsController).to receive(:authenticate_all_casa_admin!).and_call_original
  }

  describe "GET /new" do
    it "allows access to the new admin page" do
      get new_all_casa_admins_casa_org_casa_admin_path(casa_org)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    subject { post all_casa_admins_casa_org_casa_admins_path(casa_org), params: }

    context "with valid parameters" do
      let(:params) { {casa_admin: {email: "admin1@example.com", display_name: "Example Admin"}} }
      it "creates a new CASA admin for the organization" do
        expect { subject }.to change(CasaAdmin, :count).by(1)
      end

      it { is_expected.to redirect_to all_casa_admins_casa_org_path(casa_org) }

      it "shows correct flash message" do
        subject
        expect(flash[:notice]).to include("New admin created successfully")
      end
    end

    context "with invalid parameters" do
      let(:params) { {casa_admin: {email: "", display_name: ""}} }
      it "renders new page" do
        expect { subject }.not_to change(CasaAdmin, :count)

        expect(response).to be_successful
        expect(response).to render_template "casa_admins/new"
      end
    end
  end

  describe "GET /edit" do
    subject { get edit_all_casa_admins_casa_org_casa_admin_path(casa_org, casa_admin) }

    it "should allow access to the edit admin page" do
      subject
      expect(response).to be_successful
    end

    it "shows correct admin" do
      subject
      expect(response.body).to include(casa_admin.email)
    end
  end

  describe "PATCH /update" do
    subject { patch all_casa_admins_casa_org_casa_admin_path(casa_org, casa_admin), params: }

    context "with valid parameters" do
      let(:params) { {all_casa_admin: {email: "casa_admin@example.com"}} }

      it "should allow current user to successfully update other casa admin's email" do
        expect { subject }.to change { casa_admin.reload.email }.from("admin1@example.com").to("casa_admin@example.com")
      end

      it { is_expected.to redirect_to edit_all_casa_admins_casa_org_casa_admin_path(casa_org, casa_admin) }

      it "shows correct flash message" do
        subject
        expect(flash[:notice]).to include("New admin created successfully")
      end
    end

    context "with invalid parameters" do
      let(:params) { {all_casa_admin: {email: ""}} }

      it "should not allow current user to successfully update other casa admin's email" do
        expect { subject }.not_to change { casa_admin.reload.email }
      end

      it "renders new page" do
        subject
        expect(response).to be_successful
        expect(response).to render_template "casa_admins/edit"
      end
    end
  end

  describe "PATCH /activate" do
    subject { patch activate_all_casa_admins_casa_org_casa_admin_path(casa_org, casa_admin) }

    let(:casa_admin) { create(:casa_admin, :inactive) }

    it "should successfully activate another casa admin's profile" do
      expect { subject }.to change { casa_admin.reload.active }.from(false).to(true)
    end

    it "calls for CasaAdminMailer" do
      expect(CasaAdminMailer).to(
        receive(:account_setup).with(casa_admin).once.and_return(double("mailer", deliver: true))
      )
      subject
    end

    it { is_expected.to redirect_to edit_all_casa_admins_casa_org_casa_admin_path(casa_org, casa_admin) }

    it "shows correct flash message" do
      subject
      expect(flash[:notice]).to include("Admin was activated. They have been sent an email.")
    end

    context "when activation fails" do
      before { allow_any_instance_of(CasaAdmin).to receive(:activate).and_return(false) }

      it "should not activate the casa admin's profile" do
        expect { subject }.not_to change { casa_admin.reload.active }
      end

      it "renders edit page" do
        subject
        expect(response).to be_successful
        expect(response).to render_template "casa_admins/edit"
      end
    end
  end

  describe "PATCH /deactivate" do
    subject { patch deactivate_all_casa_admins_casa_org_casa_admin_path(casa_org, casa_admin) }

    let(:casa_admin) { create(:casa_admin, active: true) }

    it "should successfully deactivate another casa admin's profile" do
      expect { subject }.to change { casa_admin.reload.active }.from(true).to(false)
    end

    it "calls for CasaAdminMailer" do
      expect(CasaAdminMailer).to(
        receive(:deactivation).with(casa_admin).once.and_return(double("mailer", deliver: true))
      )
      subject
    end

    it { is_expected.to redirect_to edit_all_casa_admins_casa_org_casa_admin_path(casa_org, casa_admin) }

    it "shows correct flash message" do
      subject
      expect(flash[:notice]).to include("Admin was deactivated.")
    end

    context "when deactivation fails" do
      before { allow_any_instance_of(CasaAdmin).to receive(:deactivate).and_return(false) }

      it "should not deactivate the casa admin's profile" do
        expect { subject }.not_to change { casa_admin.reload.active }
      end

      it "renders edit page" do
        subject
        expect(response).to be_successful
        expect(response).to render_template "casa_admins/edit"
      end
    end
  end
end
