require "rails_helper"

RSpec.describe "/contact_types", type: :request do
  let(:group) { create(:contact_type_group) }
  describe "GET /contact_types/new" do
    context "logged in as admin user" do
      it "can successfully access a contact type create page" do
        sign_in_as_admin

        get new_contact_type_path

        expect(response).to be_successful
      end
    end

    context "logged in as a non-admin user" do
      it "cannot access a contact type create page" do
        sign_in_as_volunteer

        get new_contact_type_path

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "unauthenticated request" do
      it "cannot access a contact type create page" do
        get new_contact_type_path

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "POST /contact_types" do
    context "logged in as admin user" do
      it "can successfully create a contact type" do
        casa_org = create(:casa_org)
        sign_in create(:casa_admin, casa_org: casa_org)

        expect {
          post contact_types_path params: {
            contact_type: {
              name: "New Contact",
              contact_type_group_id: group.id
            }
          }
        }.to change(ContactType, :count).by(1)

        contact_type = ContactType.last

        expect(contact_type.name).to eql "New Contact"
        expect(contact_type.contact_type_group).to eql group
        expect(response).to redirect_to edit_casa_org_path(casa_org)
        expect(response.request.flash[:notice]).to eq "Contact Type was successfully created."
      end
    end

    context "logged in as a non-admin user" do
      it "cannot create a contact type" do
        sign_in_as_volunteer

        post contact_types_path params: {
          contact_type: {
            name: "New Contact",
            contact_type_group_id: group.id
          }
        }

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "unauthenticated request" do
      it "cannot create a contact type" do
        post contact_types_path params: {
          contact_type: {
            name: "New Contact",
            contact_type_group_id: group.id
          }
        }

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "GET /contact_types/:id/edit" do
    context "logged in as admin user" do
      it "can successfully access a contact type edit page" do
        sign_in_as_admin

        get edit_contact_type_path(create(:contact_type))

        expect(response).to be_successful
      end
    end

    context "logged in as a non-admin user" do
      it "cannot access a contact type edit page" do
        sign_in_as_volunteer

        get edit_contact_type_path(create(:contact_type))

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "unauthenticated request" do
      it "cannot access a contact type edit page" do
        get edit_contact_type_path(create(:contact_type))

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "PUT /contact_types/:id" do
    context "logged in as admin user" do
      it "can successfully update a contact type" do
        casa_org = create(:casa_org)
        sign_in create(:casa_admin, casa_org: casa_org)

        contact_type = create(:contact_type, contact_type_group: group)
        expected_name = "New Contact Type"
        expected_group = create(:contact_type_group, casa_org: casa_org)

        put contact_type_path(contact_type), params: {
          contact_type: {
            name: expected_name,
            contact_type_group_id: expected_group.id
          }
        }

        contact_type.reload
        expect(contact_type.name).to eq expected_name
        expect(contact_type.contact_type_group).to eq expected_group

        expect(response).to redirect_to edit_casa_org_path(casa_org)
        expect(response.request.flash[:notice]).to eq "Contact Type was successfully updated."
      end
    end

    context "logged in as a non-admin user" do
      it "cannot update a update a contact type" do
        sign_in_as_volunteer

        put contact_type_path(create(:contact_type)), params: {
          contact_type: {
            name: "New Name",
            contact_type_group_id: group.id
          }
        }

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "unauthenticated request" do
      it "cannot update a update a contact type" do
        put contact_type_path(create(:contact_type)), params: {
          contact_type: {
            name: "New Name",
            contact_type_group_id: group.id
          }
        }

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
