# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/supervisors", type: :request do
  let(:admin) { create(:casa_admin) }
  let(:supervisor) { create(:supervisor) }

  describe "GET /new" do
    it "admin can view the new supervisor page" do
      sign_in admin

      get new_supervisor_url

      expect(response).to be_successful
    end

    it "supervisors can not view the new supervisor page" do
      sign_in supervisor

      get new_supervisor_url

      expect(response).to_not be_successful
    end
  end

  describe "GET /edit" do
    it "admin can view the edit supervisor page" do
      sign_in admin

      get edit_supervisor_url(supervisor)

      expect(response).to be_successful
    end

    it "supervisor can view the edit supervisor page" do
      sign_in supervisor

      get edit_supervisor_url(supervisor)

      expect(response).to be_successful
    end

    it "other supervisor can view the edit supervisor page" do
      sign_in create(:supervisor)

      get edit_supervisor_url(supervisor)

      expect(response).to be_successful
    end
  end

  describe "PATCH /update" do
    context "while signed in as an admin" do
      before do
        sign_in admin
      end

      it "admin updates the supervisor" do
        patch supervisor_path(supervisor), params: update_supervisor_params
        supervisor.reload

        expect(supervisor.display_name).to eq "New Name"
        expect(supervisor.email).to eq "newemail@gmail.com"
      end

      it "can set the supervisor to be inactive" do
        patch supervisor_path(supervisor), params: { supervisor: { active: false } }
        supervisor.reload

        expect(supervisor).not_to be_active
      end
    end

    context "while signed in as a supervisor" do
      before do
        sign_in supervisor
      end

      it "supervisor updates their own name and email" do
        patch supervisor_path(supervisor), params: update_supervisor_params
        supervisor.reload

        expect(supervisor.display_name).to eq "New Name"
        expect(supervisor.email).to eq "newemail@gmail.com"
        expect(supervisor).to be_active
      end

      it "cannot change its own type" do
        patch supervisor_path(supervisor), params: update_supervisor_params.merge(type: "casa_admin")
        supervisor.reload

        expect(supervisor).not_to be_casa_admin
      end

      it "cannot set itself to be inactive" do
        patch supervisor_path(supervisor), params: update_supervisor_params.merge(active: false)
        supervisor.reload

        expect(supervisor).to be_active
      end

      it "supervisor cannot update another supervisor" do
        supervisor2 = create(:supervisor, display_name: "Old Name", email: "oldemail@gmail.com")

        patch supervisor_path(supervisor2), params: update_supervisor_params
        supervisor2.reload

        expect(supervisor2.display_name).to eq "Old Name"
        expect(supervisor2.email).to eq "oldemail@gmail.com"
        expect(response).to redirect_to(root_url)
      end
    end
  end

  def update_supervisor_params
    {supervisor: {email: "newemail@gmail.com", display_name: "New Name"}}
  end
end
