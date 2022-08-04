require "rails_helper"

RSpec.describe AllCasaAdminsController, type: :controller do
  let(:all_casa_admin) { create(:all_casa_admin) }

  before do
    sign_in all_casa_admin
  end

  describe "GET new" do
    it "should load the page" do
      get :new
      expect(response).to be_successful
    end

    it "should authenticate the user" do
      sign_out all_casa_admin
      get :new
      expect(response).to have_http_status(:redirect)
    end

    it "only allows all_casa_admin users" do
      sign_out all_casa_admin
      casa_admin = create(:casa_admin)
      sign_in casa_admin
      get :new
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "POST create" do
    it "creates new all_casa_admin users", :aggregate_failures do
      expect {
        post :create, params: {
          all_casa_admin: {
            email: "admin1@example.com"
          }
        }
      }.to change(AllCasaAdmin, :count).by(1)
      expect(response).to have_http_status(:redirect)
      expect(flash[:notice]).to eq("New All CASA admin created successfully")
    end

    it "also responds as json", :aggregate_failures do
      post :create, format: :json, params: {
        all_casa_admin: {
          email: "admin1@example.com"
        }
      }
      expect(response).to have_http_status(:created)
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(response.body).to match("admin1@example.com".to_json)
    end

    it "email can't be blank" do
      post :create, params: {
        all_casa_admin: {
          email: ""
        }
      }
      expect(response).to render_template "all_casa_admins/new"
    end

    it "handles blank emails in json format", :aggregate_failures do
      post :create, format: :json, params: {
        all_casa_admin: {
          email: ""
        }
      }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(response.body).to match("Email can't be blank".to_json)
    end
  end

  describe "PATCH update" do
    it "updates all_casa_admin users", :aggregate_failures do
      patch :update, params: {
        all_casa_admin: {
          email: "updated_admin1@example.com"
        }
      }
      expect(response).to have_http_status(:redirect)
      expect(flash[:success]).to eq("Profile was successfully updated.")
      expect(AllCasaAdmin.first.email).to eq "updated_admin1@example.com"
    end

    it "responds in json format", :aggregate_failures do
      patch :update, format: :json, params: {
        all_casa_admin: {
          email: "updated_admin1@example.com"
        }
      }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(response.body).to match("updated_admin1@example.com".to_json)
    end

    it "email can't be blank" do
      patch :update, params: {
        all_casa_admin: {
          email: ""
        }
      }
      expect(response).to render_template "all_casa_admins/edit"
    end

    it "handles blank emails in json format", :aggregate_failures do
      patch :update, format: :json, params: {
        all_casa_admin: {
          email: ""
        }
      }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(response.body).to match("Email can't be blank".to_json)
    end
  end

  describe "PATCH update_password" do
    it "updates the all_casa_admin password", :aggregate_failures do
      patch :update_password, params: {
        all_casa_admin: {
          password: "updated_password",
          password_confirmation: "updated_password"
        }
      }
      expect(response).to have_http_status(:redirect)
      expect(flash[:success]).to eq("Password was successfully updated.")
      expect(AllCasaAdmin.first.valid_password?("updated_password")).to be true
    end

    it "responds in json format", :aggregate_failures do
      patch :update_password, format: :json, params: {
        all_casa_admin: {
          password: "updated_password",
          password_confirmation: "updated_password"
        }
      }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(response.body).to match("Password was successfully updated.")
    end

    it "handles invalid password confirmation", :aggregate_failures do
      patch :update_password, params: {
        all_casa_admin: {
          password: "updated_password",
          password_confirmation: "some_other_value"
        }
      }
      expect(response).to have_http_status(:ok)
      expect(response).to render_template "all_casa_admins/edit"
      expect(AllCasaAdmin.first.valid_password?("updated_password")).to be false
    end

    it "handles invalid password confirmation in json format", :aggregate_failures do
      patch :update_password, format: :json, params: {
        all_casa_admin: {
          password: "updated_password",
          password_confirmation: "some_other_value"
        }
      }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(response.body).to match("Password confirmation doesn't match Password".to_json)
    end
  end
end
