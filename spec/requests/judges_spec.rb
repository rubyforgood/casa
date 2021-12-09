require "rails_helper"

RSpec.describe "/judges", type: :request do
  describe "GET /judges/new" do
    context "logged in as admin user" do
      it "can successfully access a judge create page" do
        sign_in_as_admin

        get new_judge_path

        expect(response).to be_successful
      end
    end

    context "logged in as a non-admin user" do
      it "cannot access a judge create page" do
        sign_in_as_volunteer

        get new_judge_path

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "unauthenticated request" do
      it "cannot access a judge create page" do
        get new_judge_path

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "POST /judges" do
    let(:params) { {judge: {name: "Joe Judge", active: true}} }

    context "logged in as admin user" do
      it "can successfully create a judge" do
        casa_org = build(:casa_org)
        sign_in build(:casa_admin, casa_org: casa_org)

        expect {
          post judges_path, params: params
        }.to change(Judge, :count).by(1)

        judge = Judge.last

        expect(judge.name).to eql "Joe Judge"
        expect(judge.casa_org).to eql casa_org
        expect(judge.active).to be_truthy
        expect(response).to redirect_to edit_casa_org_path(casa_org)
        expect(response.request.flash[:notice]).to eq "Judge was successfully created."
      end
    end

    context "logged in as a non-admin user" do
      it "cannot create a judge" do
        sign_in_as_volunteer

        post judges_path, params: params

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "unauthenticated request" do
      it "cannot create a judge" do
        post judges_path, params: params

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "GET /judges/:id/edit" do
    let(:judge) { create(:judge) }

    context "logged in as admin user" do
      it "can successfully access a judge edit page" do
        sign_in_as_admin

        get edit_judge_path(judge)

        expect(response).to be_successful
      end
    end

    context "logged in as a non-admin user" do
      it "cannot access a judge edit page" do
        sign_in_as_volunteer

        get edit_judge_path(judge)

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "unauthenticated request" do
      it "cannot access a judge edit page" do
        get edit_judge_path(judge)

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "PUT /judges/:id" do
    let(:judge) { create(:judge) }
    let(:params) { {judge: {name: "New Name", judge_id: judge.id, active: false}} }

    context "logged in as admin user" do
      it "can successfully update a judge" do
        casa_org = build(:casa_org)
        sign_in build(:casa_admin, casa_org: casa_org)

        put judge_path(judge), params: params

        judge.reload
        expect(judge.name).to eq "New Name"
        expect(judge.active).to be_falsey

        expect(response).to redirect_to edit_casa_org_path(casa_org)
        expect(response.request.flash[:notice]).to eq "Judge was successfully updated."
      end
    end

    context "logged in as a non-admin user" do
      it "cannot update a judge" do
        sign_in_as_volunteer

        put judge_path(judge), params: params

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "unauthenticated request" do
      it "cannot update a judge" do
        put judge_path(judge), params: params

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
