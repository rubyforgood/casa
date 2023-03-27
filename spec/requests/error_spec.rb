require "rails_helper"

RSpec.describe "/error", type: :request do
  let(:organization) { create(:casa_org) }
  let!(:admin) { create(:casa_admin, casa_org: organization) }
  let!(:volunteer) { create(:volunteer, casa_org: organization) }
  let!(:supervisor) { create(:supervisor, casa_org: organization) }

  describe "GET /error" do
    context "when logged in as admin user" do
      it "500s the app" do
        sign_in admin

        get error_path

        expect(response).to raise_error(Errors::StandardError)
      end
    end

    context "when logged in as volunteer" do
      it "500s the app" do
        sign_in volunteer

        get error_path

        expect(response).to raise_error(Errors::StandardError)
      end
    end

    context "when logged in as supervisor" do
      it "500s the app" do
        sign_in supervisor

        get error_path

        expect(response).to raise_error(Errors::StandardError)
      end
    end

    context "when not logged in" do
      it "500s the app" do
        get error_path

        expect(response).to raise_error(Errors::StandardError)
      end
    end
  end
end
