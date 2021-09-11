require "rails_helper"

RSpec.describe "/contact_type_groups", type: :request do
  describe "GET /contact_type_groups/new" do
    context "logged in as admin user" do
      it "can successfully access a contact type group create page" do
        sign_in_as_admin

        get new_contact_type_group_path

        expect(response).to be_successful
      end
    end

    context "logged in as a non-admin user" do
      it "cannot access a contact type group create page" do
        sign_in_as_volunteer

        get new_contact_type_group_path

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "unauthenticated request" do
      it "cannot access a contact type group create page" do
        get new_contact_type_group_path

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "POST /contact_type_groups" do
    let(:params) { {contact_type_group: {name: "New Group", active: true}} }

    context "logged in as admin user" do
      it "can successfully create a contact type group" do
        casa_org = build(:casa_org)
        sign_in build(:casa_admin, casa_org: casa_org)

        expect {
          post contact_type_groups_path, params: params
        }.to change(ContactTypeGroup, :count).by(1)

        group = ContactTypeGroup.last

        expect(group.name).to eql "New Group"
        expect(group.casa_org).to eql casa_org
        expect(group.active).to be_truthy
        expect(response).to redirect_to edit_casa_org_path(casa_org)
        expect(response.request.flash[:notice]).to eq "Contact Type Group was successfully created."
      end
    end

    context "logged in as a non-admin user" do
      it "cannot create a contact type group" do
        sign_in_as_volunteer

        post contact_type_groups_path, params: params

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "unauthenticated request" do
      it "cannot create a contact type group" do
        post contact_type_groups_path, params: params

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

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
    let(:params) { {contact_type_group: {name: "New Group Name", active: false}} }

    context "logged in as admin user" do
      it "can successfully update a contact type group" do
        casa_org = build(:casa_org)
        sign_in build(:casa_admin, casa_org: casa_org)

        group = create(:contact_type_group, casa_org: casa_org, active: true)

        put contact_type_group_path(group), params: params

        group.reload
        expect(group.name).to eq "New Group Name"
        expect(group.casa_org).to eq casa_org
        expect(group.active).to be_falsey

        expect(response).to redirect_to edit_casa_org_path(casa_org)
        expect(response.request.flash[:notice]).to eq "Contact Type Group was successfully updated."
      end
    end

    context "logged in as a non-admin user" do
      it "cannot update a update a contact type group" do
        sign_in_as_volunteer

        put contact_type_group_path(create(:contact_type_group)), params: params

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "unauthenticated request" do
      it "cannot update a update a contact type group" do
        put contact_type_group_path(create(:contact_type_group)), params: params

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
