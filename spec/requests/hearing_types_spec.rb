require "rails_helper"

RSpec.describe "/hearing_types", type: :request do
  describe "GET /hearing_types/new" do
    context "when logged in as admin user" do
      it "allows access to hearing type create page" do
        sign_in_as_admin

        get new_hearing_type_path

        expect(response).to be_successful
      end
    end

    context "when logged in as a non-admin user" do
      it "does not allow access to hearing type create page" do
        sign_in_as_volunteer

        get new_hearing_type_path

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "when an unauthenticated request is made" do
      it "does not allow access to hearing type create page" do
        get new_hearing_type_path

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "POST /hearing_types" do
    let(:params) { {hearing_type: {name: "New Hearing", active: true}} }

    context "when logged in as admin user" do
      it "successfully create a hearing type" do
        casa_org = create(:casa_org)
        sign_in create(:casa_admin, casa_org: casa_org)

        expect {
          post hearing_types_path, params: params
        }.to change(HearingType, :count).by(1)

        hearing_type = HearingType.last

        expect(hearing_type.name).to eql "New Hearing"
        expect(hearing_type.active).to be_truthy
        expect(response).to redirect_to edit_casa_org_path(casa_org)
        expect(response.request.flash[:notice]).to eq "Hearing Type was successfully created."
      end
    end

    context "when logged in as a non-admin user" do
      it "does not create a hearing type" do
        sign_in_as_volunteer

        post hearing_types_path, params: params

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "when an unauthenticated request is made" do
      it "does not create a hearing type" do
        post hearing_types_path, params: params

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "GET /hearing_types/:id/edit" do
    context "when logged in as admin user" do
      it "allows access to hearing type edit page" do
        sign_in_as_admin

        get edit_hearing_type_path(create(:hearing_type))

        expect(response).to be_successful
      end
    end

    context "when logged in as a non-admin user" do
      it "does not allow access to hearing type edit page" do
        sign_in_as_volunteer

        get edit_hearing_type_path(create(:hearing_type))

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "when an unauthenticated request is made" do
      it "does not allow access to hearing type edit page" do
        get edit_hearing_type_path(create(:hearing_type))

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "PUT /hearing_types/:id" do
    let(:casa_org) { create(:casa_org) }
    let(:params) { {hearing_type: {name: "New Name", active: true}} }

    context "when logged in as admin user" do
      it "successfully update hearing type with active status" do
        sign_in create(:casa_admin, casa_org: casa_org)

        hearing_type = create(:hearing_type)

        put hearing_type_path(hearing_type), params: params

        hearing_type.reload
        expect(hearing_type.name).to eq "New Name"
        expect(hearing_type.active).to be_truthy

        expect(response).to redirect_to edit_casa_org_path(casa_org)
        expect(response.request.flash[:notice]).to eq "Hearing Type was successfully updated."
      end

      it "successfully update hearing type with inactive status" do
        sign_in create(:casa_admin, casa_org: casa_org)

        hearing_type = create(:hearing_type)

        put hearing_type_path(hearing_type), params: params

        hearing_type.update(active: false)
        hearing_type.reload
        expect(hearing_type.name).to eq "New Name"
        expect(hearing_type.active).to be_falsey

        expect(response).to redirect_to edit_casa_org_path(casa_org)
        expect(response.request.flash[:notice]).to eq "Hearing Type was successfully updated."
      end
    end

    context "when logged in as a non-admin user" do
      it "does not update hearing type" do
        sign_in_as_volunteer

        put hearing_type_path(create(:hearing_type)), params: params

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "when an unauthenticated request is made" do
      it "does not update hearing type" do
        put hearing_type_path(create(:hearing_type)), params: params

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
