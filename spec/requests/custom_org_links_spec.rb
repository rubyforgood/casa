require "rails_helper"

RSpec.describe "/custom_org_links", type: :request do
  let(:casa_org) { create(:casa_org) }
  let(:casa_admin) { create :casa_admin, casa_org: casa_org }
  let(:volunteer) { create :volunteer, casa_org: casa_org, active: true }

  describe "GET /custom_org_links/new" do
    context "when logged in as admin user" do
      before { sign_in casa_admin }

      it "can successfully access a custom org link create page" do
        get new_custom_org_link_path
        expect(response).to be_successful
      end
    end

    context "when logged in as a non-admin user" do
      before { sign_in volunteer }

      it "cannot access a custom org link create page" do
        get new_custom_org_link_path
        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "when not logged in" do
      it "cannot access a custom org link create page" do
        get new_custom_org_link_path
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "POST /custom_org_links" do
    let(:params) { {custom_org_link: {text: "New Custom Link", url: "http://www.custom.link", active: true}} }

    context "when logged in as admin user" do
      let(:expected_custom_link_attributes) { params[:custom_org_link].merge(casa_org_id: casa_org.id).stringify_keys }
      before { sign_in casa_admin }

      it "can successfully create a custom org link" do
        expect { post custom_org_links_path, params: params }.to change { CustomOrgLink.count }.by(1)
        expect(CustomOrgLink.last.attributes).to include(**expected_custom_link_attributes)
        expect(response).to redirect_to edit_casa_org_path(casa_org)
        expect(response.request.flash[:notice]).to eq "Custom link was successfully created."
      end
    end

    context "when logged in as a non-admin user" do
      before { sign_in volunteer }

      it "cannot create a custom org link" do
        post custom_org_links_path, params: params
        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "when not logged in" do
      it "cannot create a custom org link" do
        post custom_org_links_path, params: params
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "GET /custom_org_links/:id/edit" do
    context "when logged in as admin user" do
      before { sign_in_as_admin }

      it "can successfully access a contact type edit page" do
        get edit_custom_org_link_path(create(:custom_org_link))
        expect(response).to be_successful
      end
    end

    context "when logged in as a non-admin user" do
      before { sign_in_as_volunteer }

      it "cannot access a contact type edit page" do
        get edit_custom_org_link_path(create(:custom_org_link))
        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "when not logged in" do
      it "cannot access a contact type edit page" do
        get edit_custom_org_link_path(create(:custom_org_link))
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "PUT /custom_org_links/:id" do
    let!(:custom_org_link) { create :custom_org_link, casa_org: casa_org, text: "Existing Link", url: "http://existing.com", active: false }
    let(:params) { {custom_org_link: {text: "New Custom Link", url: "http://www.custom.link", active: true}} }

    context "when logged in as admin user" do
      let(:expected_custom_link_attributes) { params[:custom_org_link].merge(casa_org_id: casa_org.id).stringify_keys }
      before { sign_in casa_admin }

      it "can successfully update a custom org link" do
        expect { put custom_org_link_path(custom_org_link), params: params }.to_not change { CustomOrgLink.count }
        expect(custom_org_link.reload.attributes).to include(**expected_custom_link_attributes)
        expect(response).to redirect_to edit_casa_org_path(casa_org)
        expect(response.request.flash[:notice]).to eq "Custom link was successfully updated."
      end
    end

    context "when logged in as a non-admin user" do
      before { sign_in volunteer }

      it "cannot update a custom org link" do
        put custom_org_link_path(custom_org_link), params: params
        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "when not logged in" do
      it "cannot update a custom org link" do
        put custom_org_link_path(custom_org_link), params: params
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "DELETE /custom_org_links/:id" do
    let!(:custom_org_link) { create :custom_org_link, casa_org: casa_org, text: "Existing Link", url: "http://existing.com", active: false }

    context "when logged in as admin user" do
      before { sign_in casa_admin }

      it "can successfully delete a custom org link" do
        expect { delete custom_org_link_path(custom_org_link) }.to change { CustomOrgLink.count }.by(-1)
        expect(response).to redirect_to edit_casa_org_path(casa_org)
        expect(response.request.flash[:notice]).to eq "Custom link was successfully deleted."
      end
    end

    context "when logged in as a non-admin user" do
      before { sign_in volunteer }

      it "cannot delete a custom org link" do
        delete custom_org_link_path(custom_org_link)
        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "when not logged in" do
      it "cannot delete a custom org link" do
        delete custom_org_link_path(custom_org_link)
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
