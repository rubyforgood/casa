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
      let(:params) { { casa_admin: { email: "admin1@example.com", display_name: "Example Admin" } } }
      it "creates a new CASA admin for the organization" do
        expect { subject }.to change(CasaAdmin, :count).by(1)
      end

      it { is_expected.to redirect_to all_casa_admins_casa_org_path(casa_org) }
      
      it 'shows correct flash message' do
        subject 
        expect(flash[:notice]).to include('New admin created successfully')
      end
    end


    context "with invalid parameters" do
      let(:params) { { casa_admin: { email: "", display_name: "" } } }
      it "renders new page" do
        expect{subject}.not_to change(CasaAdmin, :count)

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
    subject { patch edit_all_casa_admins_casa_org_casa_admins_path(casa_org, casa_admin), params: }
    context "with valid parameters" do
      let(:params) { { casa_admin: { email: "admin1@example.com" } } }
      it "creates a new CASA admin for the organization" do
        expect { subject }.to change(CasaAdmin, :count).by(1)
      end

      it { is_expected.to redirect_to all_casa_admins_casa_org_path(casa_org) }

      it 'shows correct flash message' do
        subject 
        expect(flash[:notice]).to include('New admin created successfully')
      end
    end


    context "with invalid parameters" do
      let(:params) { { casa_admin: { email: "", display_name: "" } } }
      it "renders new page" do
        expect{subject}.not_to change(CasaAdmin, :count)

        expect(response).to be_successful
        expect(response).to render_template "casa_admins/new"
      end
    end
  end

  describe "PATCH /update" do
    subject { patch edit_all_casa_admins_casa_org_casa_admin_path(casa_org, casa_admin) }

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

end
