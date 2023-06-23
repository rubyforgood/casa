# frozen_string_literal: true

require "rails_helper"
require "support/stubbed_requests/webmock_helper"

RSpec.describe "/supervisors", type: :request do
  let(:org) { create(:casa_org) }
  let(:admin) { build(:casa_admin, casa_org: org) }
  let(:supervisor) { create(:supervisor, casa_org: org) }

  let(:update_supervisor_params) do
    {supervisor: {display_name: "New Name", phone_number: "+14163218092"}}
  end
  # add domains to blacklist you want to stub
  blacklist = ["api.twilio.com", "api.short.io"]
  web_mock = WebMockHelper.new(blacklist)
  web_mock.stub_network_connection

  describe "GET /index" do
    it "returns http status ok" do
      sign_in admin

      get supervisors_path

      expect(response).to have_http_status(:ok)
    end

    context "when casa case has court_dates" do
      let!(:casa_case) { create(:casa_case, casa_org: org, court_dates: [court_date]) }
      let(:court_date) { create(:court_date) }

      it "does not return casa case" do
        sign_in admin

        get supervisors_path

        expect(response.body).not_to include(casa_case.case_number)
      end
    end

    context "when casa case does not have court_dates" do
      let!(:casa_case) { create(:casa_case, casa_org: org, court_dates: []) }

      it "does not return casa case" do
        sign_in admin

        get supervisors_path

        expect(response.body).to include(casa_case.case_number)
      end
    end
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
    context "same org" do
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
        sign_in build(:supervisor, casa_org: org)

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

    context "different org" do
      let(:diff_org) { create(:casa_org) }
      let(:supervisor_diff_org) { create(:supervisor, casa_org: diff_org) }
      it "admin cannot view the edit supervisor page" do
        sign_in_as_admin

        get edit_supervisor_url(supervisor_diff_org)

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
      it "supervisor cannot view the edit supervisor page" do
        sign_in_as_supervisor

        get edit_supervisor_url(supervisor_diff_org)

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
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
        expect(supervisor.phone_number).to eq "+14163218092"
      end

      it "updates supervisor email and sends a confirmation email" do
        patch supervisor_path(supervisor), params: {
          supervisor: {email: "newemail@gmail.com"}
        }

        supervisor.reload
        expect(response).to have_http_status(:redirect)

        expect(supervisor.unconfirmed_email).to eq("newemail@gmail.com")
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(ActionMailer::Base.deliveries.first).to be_a(Mail::Message)
        expect(ActionMailer::Base.deliveries.first.body.encoded)
          .to match("You can confirm your account email through the link below:")
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

      it "supervisor updates their own name" do
        patch supervisor_path(supervisor), params: update_supervisor_params
        supervisor.reload

        expect(supervisor.display_name).to eq "New Name"
        expect(supervisor).to be_active
      end

      it "supervisor updates their own email and receives a confirmation email" do
        patch supervisor_path(supervisor), params: {
          supervisor: {email: "newemail@gmail.com"}
        }

        supervisor.reload
        expect(response).to have_http_status(:redirect)
        expect(supervisor.unconfirmed_email).to eq("newemail@gmail.com")
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(ActionMailer::Base.deliveries.first).to be_a(Mail::Message)
        expect(ActionMailer::Base.deliveries.first.body.encoded)
          .to match("You can confirm your account email through the link below:")
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
    before do
      @twilio_activation_success_stub = WebMockHelper.twilio_activation_success_stub("supervisor")
      @twilio_activation_error_stub = WebMockHelper.twilio_activation_error_stub("supervisor")
      @short_io_stub = WebMockHelper.short_io_stub_sms
    end

    let(:params) do
      {
        supervisor: {
          display_name: "Display Name",
          email: "displayname@example.com"
        }
      }
    end

    it "sends an invitation email" do
      sign_in admin

      post supervisors_url, params: params

      expect(Devise.mailer.deliveries.count).to eq(1)
      expect(Devise.mailer.deliveries.first.text_part.body.to_s).to include(admin.casa_org.display_name)
      expect(Devise.mailer.deliveries.first.text_part.body.to_s).to include("This is the first step to accessing your new Supervisor account.")
    end

    it "sends a SMS when a phone number exists" do
      sign_in admin
      params[:supervisor][:phone_number] = "+12222222222"
      post supervisors_url, params: params
      expect(@short_io_stub).to have_been_requested.times(2)
      expect(@twilio_activation_success_stub).to have_been_requested.times(1)
      expect(response).to have_http_status(:redirect)
      follow_redirect!
      expect(flash[:notice]).to match(/New supervisor created successfully. SMS has been sent!/)
    end

    it "does not send a SMS if phone number not given" do
      sign_in admin
      post supervisors_url, params: params
      expect(@short_io_stub).to have_been_requested.times(0)
      expect(@twilio_activation_success_stub).to have_been_requested.times(0)
      expect(@twilio_activation_error_stub).to have_been_requested.times(0)
      expect(response).to have_http_status(:redirect)
      follow_redirect!
      expect(flash[:notice]).to match(/New supervisor created successfully./)
    end

    it "does not send a SMS if Twilio has an error" do
      # ex. credentials entered wrong
      org = create(:casa_org, twilio_account_sid: "articuno31")
      admin = build(:casa_admin, casa_org: org)

      sign_in admin

      params[:supervisor][:phone_number] = "+12222222222"
      post supervisors_url, params: params
      expect(@twilio_activation_error_stub).to have_been_requested.times(1)
      expect(response).to have_http_status(:redirect)
      follow_redirect!
      expect(flash[:notice]).to match(/New supervisor created successfully. SMS not sent. Error: ./)
    end

    it "does not send a SMS if the casa_org does not have Twilio enabled" do
      org = create(:casa_org, twilio_enabled: false)
      admin = build(:casa_admin, casa_org: org)

      sign_in admin

      params[:supervisor][:phone_number] = "+12222222222"
      post supervisors_url, params: params
      expect(response).to have_http_status(:redirect)
      follow_redirect!
      expect(flash[:notice]).to match(/New supervisor created successfully./)
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

  describe "PATCH /change_to_admin" do
    let(:user) { User.find(supervisor.id) } # find the user after their type has changed

    context "when signed in as an admin" do
      before do
        sign_in admin
        patch change_to_admin_supervisor_path(supervisor)
      end

      it "changes the supervisor to an admin" do
        expect(user).not_to be_supervisor
        expect(user).to be_casa_admin
      end

      it "redirects to the edit page for an admin" do
        expect(response).to redirect_to(edit_casa_admin_path(supervisor))
      end
    end

    context "when signed in as a supervisor" do
      before do
        sign_in supervisor
        patch change_to_admin_supervisor_path(supervisor)
      end

      it "does not changes the supervisor to an admin" do
        expect(user).to be_supervisor
        expect(user).not_to be_casa_admin
      end
    end
  end
end
