require "rails_helper"

RSpec.describe "/error", type: :request do
  let(:organization) { create(:casa_org) }
  let!(:admin) { create(:casa_admin, casa_org: organization) }
  let!(:volunteer) { create(:volunteer, casa_org: organization) }
  let!(:supervisor) { create(:supervisor, casa_org: organization) }

  describe "GET /error" do
    context "when logged in as admin user" do
      it "raises an error causing an internal server error" do
        sign_in admin

        expect {
          get error_path
        }.to raise_error(StandardError, /This is an intentional test exception/)
      end
    end

    context "when logged in as volunteer" do
      it "raises an error causing an internal server error" do
        sign_in volunteer

        expect {
          get error_path
        }.to raise_error(StandardError, /This is an intentional test exception/)
      end
    end

    context "when logged in as supervisor" do
      it "raises an error causing an internal server error" do
        sign_in supervisor

        expect {
          get error_path
        }.to raise_error(StandardError, /This is an intentional test exception/)
      end
    end

    context "when not logged in" do
      it "raises an error causing an internal server error" do

        expect {
          get error_path
        }.to raise_error(StandardError, /This is an intentional test exception/)
      end
    end
  end
end
