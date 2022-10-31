require "rails_helper"

RSpec.describe CasaOrgController, type: :controller do
  let(:admin) { create(:casa_admin) }
  let(:valid_attributes) {
    {
      name: "name",
      display_name: "display_name",
      address: "address",
      twilio_account_sid: "articuno34",
      twilio_api_key_sid: "Aladdin",
      twilio_api_key_secret: "open sesame",
      twilio_phone_number: "+12223334444"
    }
  }
  let(:logo) { upload_file("#{Rails.root}/spec/fixtures/company_logo.png") }

  context "when logged in as an admin user" do
    before do
      sign_in admin
    end

    describe "GET edit" do
      it "should successfully load the page" do
        get :edit, params: {id: create(:casa_org).id}
        expect(response).to be_successful
      end
    end

    describe "PATCH update" do
      it "should preform successful updates", :aggregate_failures do
        stub_twillio
        casa_org = admin.casa_org
        patch :update, params: {
          id: casa_org.id,
          casa_org: valid_attributes
        }
        casa_org.reload
        expect(casa_org.name).to eq "name"
        expect(casa_org.display_name).to eq "display_name"
        expect(casa_org.address).to eq "address"
        expect(casa_org.twilio_account_sid).to eq "articuno34"
        expect(casa_org.twilio_api_key_sid).to eq "Aladdin"
        expect(casa_org.twilio_api_key_secret).to eq "open sesame"
        expect(casa_org.twilio_phone_number).to eq "+12223334444"
      end

      it "should raise error if any of the twillo invalid crendentials are present", :aggregate_failures do
        invalid_attributes = {
          name: "name",
          display_name: "display_name",
          address: "address",
          twilio_account_sid: "",
          twilio_api_key_sid: "",
          twilio_api_key_secret: "open sesame",
          twilio_phone_number: "+12223334444"
        }
        casa_org = admin.casa_org
        patch :update, params: {
          id: casa_org.id,
          casa_org: invalid_attributes
        }
        expect(assigns(:casa_org).errors.full_messages).to include("Your Twilio credentials are incorrect, kindly check and try again.")
      end

      it "should redirect to the edit page" do
        stub_twillio
        casa_org = admin.casa_org
        patch :update, params: {
          id: casa_org.id,
          casa_org: valid_attributes
        }
        expect(response).to redirect_to(edit_casa_org_path)
      end

      it "can upload the logo" do
        stub_twillio
        casa_org = admin.casa_org
        expect {
          patch :update, params: {
            id: casa_org.id,
            casa_org: {logo: logo}
          }
        }.to change(ActiveStorage::Attachment, :count).by(1)
      end

      it "doesn't revert logo to default if non logo details are updated" do
        stub_twillio
        casa_org = admin.casa_org
        casa_org.update(logo: logo)
        expect {
          patch :update, params: {
            id: casa_org.id,
            casa_org: valid_attributes
          }
        }.not_to change(ActiveStorage::Attachment, :count)
      end

      it "also responds as json", :aggregate_failures do
        stub_twillio
        casa_org = admin.casa_org
        patch :update, format: :json, params: {
          id: casa_org.id,
          casa_org: valid_attributes
        }
        expect(response.content_type).to eq "application/json; charset=utf-8"
        expect(response).to have_http_status :ok
        expect(response.body).to match("display_name".to_json)
      end
    end
  end
end

def stub_twillio
  twillio_client = instance_double(Twilio::REST::Client)
  messages = instance_double(Twilio::REST::Api::V2010::AccountContext::MessageList)
  allow(Twilio::REST::Client).to receive(:new).with("Aladdin", "open sesame", "articuno34").and_return(twillio_client)
  allow(twillio_client).to receive(:messages).and_return(messages)
  allow(messages).to receive(:list).and_return([])
end
