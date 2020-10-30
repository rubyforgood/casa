require "rails_helper"

RSpec.describe "/dashboard", type: :request do
  let(:organization) { create(:casa_org) }
  let(:volunteer) { create(:volunteer, casa_org: organization) }
  let(:admin) { create(:casa_admin, casa_org: organization) }

  context "as a volunteer" do
    before do
      sign_in volunteer
    end

    describe "GET /show" do
      it "renders a successful response" do
        get root_url

        expect(response).to redirect_to(casa_cases_path)
      end

      it "shows my cases"
      it "doesn't show other volunteers' cases"
      it "doesn't show other organizations' cases"
    end
  end

  context "as an admin" do
    before do
      sign_in admin
    end

    describe "GET /show" do
      it "renders a successful response" do
        get root_url

        expect(response).to redirect_to(supervisors_path)
      end

      it "shows all my organization's cases"
      it "doesn't show other organizations' cases"
    end
  end
end
