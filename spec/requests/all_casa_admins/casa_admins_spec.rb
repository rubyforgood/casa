require "rails_helper"

RSpec.describe "/all_casa_admins/casa_orgs/:casa_org_id/casa_admins" do
  let(:all_casa_admin) { create(:all_casa_admin) }
  let(:casa_org) { create(:casa_org) }

  before { sign_in all_casa_admin }

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new CASA admin for the organization" do
        expect {
          post all_casa_admins_casa_org_casa_admins_path(casa_org), params: {
            casa_admin: {
              email: "admin1@example.com",
              display_name: "Example Admin",
            }
          }
        }.to change(CasaAdmin, :count).by(1)
      end
    end
  end
end
# TODO: test admin creation as an all_casa_admin