require "rails_helper"

RSpec.describe LanguagesController, type: :request do
  let(:organization) { create(:casa_org) }
  let!(:admin) { create(:casa_admin, casa_org: organization) }
  let!(:volunteer) { create(:volunteer, casa_org: organization) }
  let!(:random_lang) { create(:language, casa_org: organization) }
  let!(:casa_case) { create(:casa_case, casa_org: organization) }

  context "when logged in as an admin user" do
    before do
      sign_in admin
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    describe "#create" do
      context "when request params are valid" do
        it "should create a new language" do
          post languages_path, params: {
            language: {
              name: "Spanish"
            }
          }

          expect(response.status).to eq 302
          expect(response).to redirect_to(edit_casa_org_path(organization.id))
          expect(flash[:notice]).to eq "Language was successfully created."
        end
      end
    end

    describe "#update" do
      context "when request params are valid" do
        it "should create a new language" do
          patch language_path(random_lang), params: {
            language: {
              name: "Spanishes"
            }
          }

          expect(response.status).to eq 302
          expect(response).to redirect_to(edit_casa_org_path(organization.id))
          expect(flash[:notice]).to eq "Language was successfully updated."
        end
      end
    end
  end  
end
