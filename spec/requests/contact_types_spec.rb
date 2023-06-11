require "rails_helper"

RSpec.describe "/contact_types", type: :request do
  shared_examples "logged in as a non-admin user" do
    it "redirects to root path" do
      sign_in_as_volunteer

      subject

      expect(response).to redirect_to root_path
      expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
    end
  end
  let(:group) { create(:contact_type_group) }

  describe "GET /contact_types/new" do
    subject { get new_contact_type_path }
    context "logged in as admin user" do
      it "can successfully access a contact type create page" do
        sign_in_as_admin

        subject

        expect(response).to be_successful
      end
    end

    it_behaves_like "logged in as a non-admin user"

    context "unauthenticated request" do
      it "cannot access a contact type create page" do
        get new_contact_type_path

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "POST /contact_types" do
    let(:params) { {contact_type: {name: "New Contact", contact_type_group_id: group.id, active: true}} }
    subject { post contact_types_path, params: params }

    context "logged in as admin user" do
      it "can successfully create a contact type" do
        casa_org = build(:casa_org)
        sign_in create(:casa_admin, casa_org: casa_org)

        expect {
          post contact_types_path, params: params
        }.to change(ContactType, :count).by(1)

        contact_type = ContactType.last

        expect(contact_type.name).to eql "New Contact"
        expect(contact_type.contact_type_group).to eql group
        expect(contact_type.active).to be_truthy
        expect(response).to redirect_to edit_casa_org_path(casa_org)
        expect(response.request.flash[:notice]).to eq "Contact Type was successfully created."
        expect(assigns(:default_checked)).to be_truthy
      end
    end
    it_behaves_like "logged in as a non-admin user"

    context "unauthenticated request" do
      it "cannot create a contact type" do
        post contact_types_path, params: params

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "GET /contact_types/:id/edit" do
    subject { get edit_contact_type_path(create(:contact_type)) }
    context "logged in as admin user" do
      it "can successfully access a contact type edit page" do
        sign_in_as_admin

        subject

        expect(response).to be_successful
        expect(assigns(:default_checked)).to be_truthy
      end
    end
    it_behaves_like "logged in as a non-admin user"

    context "unauthenticated request" do
      it "cannot access a contact type edit page" do
        get edit_contact_type_path(create(:contact_type))

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "PUT /contact_types/:id" do
    let(:casa_org) { build(:casa_org) }
    let(:new_group) { create(:contact_type_group, casa_org: casa_org) }
    let(:params) { {contact_type: {name: "New Name", contact_type_group_id: new_group.id, active: false}} }

    context "logged in as admin user" do
      it "can successfully update a contact type" do
        sign_in build(:casa_admin, casa_org: casa_org)

        contact_type = create(:contact_type, contact_type_group: group)

        put contact_type_path(contact_type), params: params

        contact_type.reload
        expect(contact_type.name).to eq "New Name"
        expect(contact_type.contact_type_group).to eq new_group
        expect(contact_type.active).to be_falsey

        expect(response).to redirect_to edit_casa_org_path(casa_org)
        expect(response.request.flash[:notice]).to eq "Contact Type was successfully updated."
        expect(assigns(:default_checked)).to be_truthy
      end
    end

    context "logged in as a non-admin user" do
      it "cannot update a update a contact type" do
        sign_in_as_volunteer

        put contact_type_path(create(:contact_type)), params: params

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "unauthenticated request" do
      it "cannot update a update a contact type" do
        put contact_type_path(create(:contact_type)), params: params

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
