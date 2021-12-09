# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/supervisors", type: :request do
  let(:admin) { build(:casa_admin) }
  let(:supervisor) { create(:supervisor) }

  let(:update_supervisor_params) do
    {supervisor: {email: "newemail@gmail.com", display_name: "New Name"}}
  end

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
      sign_in build(:supervisor)

      get edit_supervisor_url(supervisor)

      expect(response).to be_successful
    end

    it "returns volunteers ever assigned if include_unassigned param is present" do
      sign_in admin

      get edit_supervisor_url(supervisor), params: {include_unassigned: true}

      expect(response).to be_successful
      expect(assigns(:all_volunteers_ever_assigned)).to_not be_nil
    end

    it "returns no volunteers ever assigned if include_unassigned param is false" do
      sign_in admin

      get edit_supervisor_url(supervisor), params: {include_unassigned: false}

      expect(response).to be_successful
      expect(assigns(:all_volunteers_ever_assigned)).to be_nil
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
        patch supervisor_path(supervisor), params: {supervisor: {active: false}}
        supervisor.reload

        expect(supervisor).not_to be_active
      end

      context "when the email exists already and the supervisor has volunteers assigned" do
        let(:other_supervisor) { create(:supervisor) }
        let(:supervisor) { create(:supervisor, :with_volunteers) }

        it "gracefully fails" do
          patch supervisor_path(supervisor), params: {supervisor: {email: other_supervisor.email}}

          expect(response).to be_successful
        end
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

  describe "POST /create" do
    it "sends an invitation email" do
      sign_in admin

      post supervisors_url, params: {supervisor: {display_name: "Display Name", email: "displayname@example.com"}}

      expect(Devise.mailer.deliveries.count).to eq(1)
      expect(Devise.mailer.deliveries.first.text_part.body.to_s).to include(admin.casa_org.display_name)
      expect(Devise.mailer.deliveries.first.text_part.body.to_s).to include("This is the first step to accessing your new Supervisor account.")
    end
  end

  describe "PATCH /activate" do
    let(:inactive_supervisor) { create(:supervisor, :inactive) }

    before { sign_in admin }

    it "activates an inactive supervisor" do
      patch activate_supervisor_path(inactive_supervisor)
      expect(flash[:notice]).to eq("Supervisor was activated. They have been sent an email.")
      inactive_supervisor.reload
      expect(inactive_supervisor.active).to be true
    end

    it "sends an activation mail" do
      expect { patch activate_supervisor_path(inactive_supervisor) }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe "PATCH /deactivate" do
    before { sign_in admin }

    it "deactivates an active supervisor" do
      patch deactivate_supervisor_path(supervisor)

      supervisor.reload
      expect(supervisor.active).to be false
    end

    it "doesn't send an deactivation email" do
      expect {
        patch deactivate_supervisor_path(supervisor)
      }.to_not change { ActionMailer::Base.deliveries.count }
    end
  end

  describe "PATCH /resend_invitation" do
    before { sign_in admin }
    it "resends an invitation email" do
      expect(supervisor.invitation_created_at.present?).to eq(false)

      patch resend_invitation_supervisor_path(supervisor)
      supervisor.reload

      expect(supervisor.invitation_created_at.present?).to eq(true)
      expect(Devise.mailer.deliveries.count).to eq(1)
      expect(Devise.mailer.deliveries.first.subject).to eq(I18n.t("devise.mailer.invitation_instructions.subject"))
      expect(response).to redirect_to(edit_supervisor_path(supervisor))
    end
  end
end
