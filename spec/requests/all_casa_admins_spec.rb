require "rails_helper"

RSpec.describe "/all_casa_admins", type: :request do
  let(:admin) { create(:all_casa_admin) }

  before(:each) { sign_in admin }

  describe "GET /new" do
    it "should authenticate the user" do
      sign_out admin
      get new_all_casa_admin_path

      expect(response).to have_http_status(:redirect)
    end

    it "only allows all_casa_admin users" do
      sign_out admin
      casa_admin = create(:casa_admin)
      sign_in casa_admin
      get new_all_casa_admin_path

      expect(response).to have_http_status(:redirect)
    end

    context "with a all_casa_admin signed in" do
      it "renders a successful response" do
        get new_all_casa_admin_path

        expect(response).to be_successful
      end
    end

    it "should authenticate the user" do
      sign_out :admin
      get new_all_casa_admin_path

      expect(response).to be_successful
    end

    it "only allows all_casa_admin users" do
      sign_out :admin
      casa_admin = create(:casa_admin)
      sign_in casa_admin
      get new_all_casa_admin_path

      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    context "with a all_casa_admin signed in" do
      it "renders a successful response" do
        get edit_all_casa_admins_path

        expect(response).to be_successful
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new All CASA admin" do
        expect do
          post all_casa_admins_path, params: {
            all_casa_admin: {
              email: "admin1@example.com"
            }
          }
        end.to change(AllCasaAdmin, :count).by(1)
        expect(response).to have_http_status(:redirect)
        expect(flash[:notice]).to eq("New All CASA admin created successfully")
      end

      it "also responds as json", :aggregate_failures do
        post all_casa_admins_path(format: :json), params: {
          all_casa_admin: {
            email: "admin1@example.com"
          }
        }

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq("application/json; charset=utf-8")
        expect(response.body).to match("admin1@example.com".to_json)
      end
    end

    context "with invalid parameters" do
      it "renders new page" do
        post all_casa_admins_path, params: {
          all_casa_admin: {
            email: ""
          }
        }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template "all_casa_admins/new"
      end

      it "also responds as json", :aggregate_failures do
        post all_casa_admins_path(format: :json), params: {
          all_casa_admin: {
            email: ""
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq("application/json; charset=utf-8")
        expect(response.body).to match("Email can't be blank".to_json)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      it "updates the all_casa_admin" do
        patch all_casa_admins_path, params: {all_casa_admin: {email: "newemail@example.com"}}
        expect(response).to have_http_status(:redirect)

        expect(admin.email).to eq "newemail@example.com"
      end

      it "also responds as json", :aggregate_failures do
        patch all_casa_admins_path(format: :json),
          params: {all_casa_admin: {email: "newemail@example.com"}}

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/json; charset=utf-8")
        expect(response.body).to match("newemail@example.com".to_json)
      end
    end

    context "with invalid parameters" do
      it "does not update the all_casa_admin" do
        other_admin = create(:all_casa_admin)
        patch all_casa_admins_path, params: {all_casa_admin: {email: other_admin.email}}
        expect(response).to have_http_status(:unprocessable_entity)

        expect(admin.email).to_not eq "newemail@example.com"
      end

      it "also responds as json", :aggregate_failures do
        other_admin = create(:all_casa_admin)
        patch all_casa_admins_path(format: :json),
          params: {all_casa_admin: {email: other_admin.email}}

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq("application/json; charset=utf-8")
        expect(response.body).to match("Email has already been taken".to_json)
      end
    end
  end

  describe "PATCH /update_password" do
    context "with valid parameters" do
      subject { patch update_password_all_casa_admins_path, params: params }

      let(:params) do
        {
          all_casa_admin: {
            password: "newpassword",
            password_confirmation: "newpassword"
          }
        }
      end

      it "updates the all_casa_admin password", :aggregate_failures do
        subject

        expect(response).to have_http_status(:redirect)
        expect(admin.valid_password?("newpassword")).to be true
      end

      it "call UserMailer.password_chaned_reminder" do
        mailer = double(UserMailer, deliver: nil)
        allow(UserMailer).to receive(:password_changed_reminder).with(admin).and_return(mailer)
        expect(mailer).to receive(:deliver)

        subject
      end

      it "also responds as json", :aggregate_failures do
        patch update_password_all_casa_admins_path(format: :json), params: params

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/json; charset=utf-8")
        expect(response.body).to match("Password was successfully updated.")
      end
    end

    context "with invalid parameters", :aggregate_failures do
      subject { patch update_password_all_casa_admins_path, params: params }

      let(:params) do
        {
          all_casa_admin: {
            password: "newpassword",
            password_confirmation: "badmatch"
          }
        }
      end

      it "does not update the all_casa_admin password" do
        subject

        expect(response).to have_http_status(:unprocessable_entity)
        expect(admin.reload.valid_password?("newpassword")).to be false
      end

      it "does not call UserMailer.password_changed_reminder" do
        mailer = double(UserMailer, deliver: nil)
        allow(UserMailer).to receive(:password_changed_reminder).with(admin).and_return(mailer)
        expect(mailer).not_to receive(:deliver)

        subject
      end

      it "also responds as json", :aggregate_failures do
        patch update_password_all_casa_admins_path(format: :json), params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq("application/json; charset=utf-8")
        expect(response.body).to match("Password confirmation doesn't match Password".to_json)
      end
    end
  end
end
