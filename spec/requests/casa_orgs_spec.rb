require "rails_helper"

RSpec.describe "CasaOrgs", type: :request do
  let(:casa_org) { create(:casa_org) }
  let(:valid_attributes) { {name: "name", display_name: "display_name", address: "address"} }
  let(:logo) { fixture_file_upload("#{Rails.root}/spec/fixtures/company_logo.png", "image/png") }
  let(:invalid_attributes) { {name: nil} }
  let(:casa_case) { create(:casa_case, casa_org: casa_org) }

  describe "as an admin" do
    before { sign_in create(:casa_admin, casa_org: casa_org) }

    describe "GET /edit" do
      it "render a successful response" do
        get edit_casa_org_url(casa_org)
        expect(response).to be_successful
      end
    end

    describe "PATCH /update" do
      context "with valid parameters" do
        it "updates the requested casa_org" do
          patch casa_org_url(casa_org), params: {casa_org: valid_attributes}
          casa_org.reload
          expect(casa_org.name).to eq "name"
          expect(casa_org.display_name).to eq "display_name"
          expect(casa_org.address).to eq "address"
        end

        it "uploads the company logo" do
          expect {
            patch casa_org_url(casa_org), params: {casa_org: {logo: logo}}
          }.to change(ActiveStorage::Attachment, :count).by(1)
        end

        it "redirects to the casa_org" do
          patch casa_org_url(casa_org), params: {casa_org: valid_attributes}
          casa_org.reload
          expect(response).to redirect_to(edit_casa_org_path)
        end
      end

      context "with invalid parameters" do
        it "renders a successful response displaying the edit template" do
          patch casa_org_url(casa_org), params: {casa_org: invalid_attributes}
          expect(response).to be_successful
          expect(response.body).to match(/error_explanation/)
        end
      end
    end
  end

  describe "as a volunteer" do
    before { sign_in create(:volunteer, casa_org: casa_org) }

    describe "GET /edit" do
      it "render a failed response" do
        get edit_casa_org_url(casa_org)
        expect(response).to redirect_to(root_url)
        expect(flash[:notice]).to match(/you are not authorized/)
      end
    end
  end
end
