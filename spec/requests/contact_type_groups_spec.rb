require "rails_helper"

RSpec.describe "/contact_type_groups", type: :request do
  describe "GET /contact_type_groups/:id/edit" do
    context "logged in as admin user" do
      it "can successfully access a contact type group edit page" do
        sign_in_as_admin

        get edit_contact_type_group_path(create(:contact_type_group))

        expect(response).to be_successful
      end
    end

    context "logged in as a non-admin user" do
      it "cannot access a contact type group edit page" do
        sign_in_as_volunteer

        get edit_contact_type_group_path(create(:contact_type_group))

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "unauthenticated request" do
      it "cannot access a contact type group edit page" do
        get edit_contact_type_group_path(create(:contact_type_group))

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "PUT /contact_type_groups/:id" do
    context "logged in as admin user" do
      it "can successfully update a contact type group" do
        casa_org = create(:casa_org)
        sign_in create(:casa_admin, casa_org: casa_org)

        group = create(:contact_type_group)
        expected_name = "New Group"

        put contact_type_group_path(group), params: {
          contact_type_group: {
            name: expected_name
          }
        }

        group.reload
        expect(group.name).to eq expected_name

        expect(response).to redirect_to edit_casa_org_path(casa_org)
        expect(response.request.flash[:notice]).to eq "Contact Type Group was successfully updated."
      end
    end

    context "logged in as a non-admin user" do
      it "cannot update a update a contact type group" do
        sign_in_as_volunteer

        put contact_type_group_path(create(:contact_type_group)), params: {
          contact_type_group: {
            name: "New Group"
          }
        }

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "unauthenticated request" do
      it "cannot update a update a contact type group" do
        put contact_type_group_path(create(:contact_type_group)), params: {
          contact_type_group: {
            name: "New Group"
          }
        }

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
