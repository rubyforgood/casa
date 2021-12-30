require "rails_helper"

RSpec.describe "CasaOrg", type: :request do
  let(:casa_org) { build(:casa_org) }
  let(:valid_attributes) { {name: "name", display_name: "display_name", address: "address"} }
  let(:logo) { upload_file("#{Rails.root}/spec/fixtures/company_logo.png") }
  let(:invalid_attributes) { {name: nil} }
  let(:casa_case) { build_stubbed(:casa_case, casa_org: casa_org) }

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

        it "doesn't revert logo to default if non logo details are updated" do
          casa_org.update(logo: logo)

          expect {
            patch casa_org_url(casa_org), params: {casa_org: valid_attributes}
          }.not_to change(ActiveStorage::Attachment, :count)
        end

        it "redirects to the casa_org" do
          patch casa_org_url(casa_org), params: {casa_org: valid_attributes}
          casa_org.reload
          expect(response).to redirect_to(edit_casa_org_path)
        end

        it "also responds as json", :aggregate_failures do
          patch casa_org_url(casa_org, format: :json), params: {casa_org: valid_attributes}

          expect(response.content_type).to eq "application/json; charset=utf-8"
          expect(response).to have_http_status :ok
          expect(response.body).to match("display_name".to_json)
        end
      end

      context "with invalid parameters" do
        it "renders a successful response displaying the edit template" do
          patch casa_org_url(casa_org), params: {casa_org: invalid_attributes}
          expect(response).to be_successful
          expect(response.body).to match(/error_explanation/)
        end

        it "also responds as json", :aggregate_failures do
          patch casa_org_url(casa_org, format: :json), params: {casa_org: invalid_attributes}

          expect(response.content_type).to eq "application/json; charset=utf-8"
          expect(response).to have_http_status :unprocessable_entity
          expect(response.body).to match "Name can't be blank".to_json
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
