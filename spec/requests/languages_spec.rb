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

  context "when logged in as a volunteer" do
    before do
      sign_in volunteer
      allow(controller).to receive(:current_user).and_return(volunteer)
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    describe "#add_to_volunteer" do
      context "when request params are valid" do
        it "should add language to current user" do
          patch add_to_volunteer_languages_path, params: {
            language_id: random_lang.id
          }

          expect(response.status).to eq 302
          expect(response).to redirect_to(edit_users_path)
          expect(flash[:notice]).to eq "#{random_lang.name} was added to your languages list."
          expect(volunteer.languages).to include random_lang
        end
      end

      context "when request params are invalid" do
        context "when the language does not exist" do
          it "should raise error" do
            expect {
              patch add_to_volunteer_languages_path, params: {
                language_id: 800
              }
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end

        context "when the language is already present for the user" do
          before { create(:user_language, user: volunteer, language: random_lang) }

          it "should raise error" do
            patch add_to_volunteer_languages_path, params: {
              language_id: random_lang.id
            }

            expect(response.status).to eq 302
            expect(response).to redirect_to(edit_users_path)
            expect(flash[:notice]).to eq "Error unable to add #{random_lang.name} to your languages list!"
          end
        end
      end
    end

    describe "#remove_from_volunteer" do
      context "when request params are valid" do
        before do
          patch add_to_volunteer_languages_path, params: {
            language_id: random_lang.id
          }
        end

        it "should remove a language from a volunteer languages list" do
          delete language_remove_from_volunteer_path(random_lang)

          expect(response.status).to eq 302
          expect(response).to redirect_to(edit_users_path)
          expect(flash[:notice]).to eq "#{random_lang.name} was removed from your languages list."
          expect(volunteer.languages).not_to include random_lang
        end
      end
      context "when request params are invalid" do
        before do
          patch add_to_volunteer_languages_path, params: {
            language_id: random_lang.id
          }
        end

        it "should raise error when Language do not exist" do
          expect { delete language_remove_from_volunteer_path(800) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
