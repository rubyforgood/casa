require "rails_helper"

RSpec.describe CasaOrgController, type: :controller do
  let(:admin) { create(:casa_admin) }

  context "when logged in as an admin user" do
    before do
      sign_in admin
    end

    describe "GET edit" do
      it "should successfully load the page" do
        get :edit, params: { id: create(:casa_org).id }
        expect(response).to be_successful
      end
    end
  end
end
