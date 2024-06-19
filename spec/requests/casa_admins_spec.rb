require "rails_helper"
require "support/stubbed_requests/webmock_helper"

RSpec.describe "/casa_admins", type: :request do
  describe "GET /casa_admins" do
    it "is successful" do
      admins = create_pair(:casa_admin)

      sign_in admins.first
      get casa_admins_path

      expect(response).to be_successful
    end
  end

  describe "GET /casa_admins/:id/edit" do
    context "logged in as admin user" do
      context "same org" do
        it "can successfully access a casa admin edit page" do
          casa_one = create(:casa_org)
          casa_admin_one = create(:casa_admin, casa_org: casa_one)

          sign_in(casa_admin_one)
          get edit_casa_admin_path(create(:casa_admin, casa_org: casa_one))

          expect(response).to be_successful
        end
      end

      context "different org" do
        it "cannot access a casa admin edit page" do
          casa_admin = create(:casa_admin)
          diff_org = create(:casa_org)
          casa_admin_diff_org = create(:casa_admin, casa_org: diff_org)

          sign_in casa_admin
          get edit_casa_admin_path(casa_admin_diff_org)

          expect(response).to redirect_to root_path
          expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
        end
      end
    end

    context "logged in as a non-admin user" do
      it "cannot access a casa admin edit page" do
        sign_in_as_volunteer
        admin = create(:casa_admin)

        get edit_casa_admin_path(admin)

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "unauthenticated request" do
      it "cannot access a casa admin edit page" do
        admin = create(:casa_admin)

        get edit_casa_admin_path(admin)

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "PUT /casa_admins/:id" do
    context "logged in as admin user" do
      it "can successfully update a casa admin user", :aggregate_failures do
        casa_admin = create(:casa_admin)
        expected_display_name = "Admin 2"
        expected_phone_number = "+14163218092"

        sign_in casa_admin

        put casa_admin_path(casa_admin), params: {
          casa_admin: {
            display_name: expected_display_name,
            phone_number: expected_phone_number
          }
        }

        casa_admin.reload
        expect(casa_admin.display_name).to eq expected_display_name
        expect(casa_admin.phone_number).to eq expected_phone_number
        expect(response).to redirect_to edit_casa_admin_path(casa_admin)
        expect(response.request.flash[:notice]).to eq "Casa Admin was successfully updated."
      end

      it "can update a casa admin user's email and send them a confirmation email", :aggregate_failures do
        casa_admin = create(:casa_admin)
        expected_email = "admin2@casa.com"

        sign_in casa_admin
        put casa_admin_path(casa_admin), params: {
          casa_admin: {
            email: expected_email
          }
        }

        casa_admin.reload
        expect(response).to have_http_status(:redirect)

        expect(casa_admin.unconfirmed_email).to eq("admin2@casa.com")
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(ActionMailer::Base.deliveries.first).to be_a(Mail::Message)
        expect(ActionMailer::Base.deliveries.first.body.encoded)
          .to match("You can confirm your account email through the link below:")
      end

      it "also respond as json", :aggregate_failures do
        casa_admin = create(:casa_admin)
        expected_display_name = "Admin 2"

        sign_in casa_admin
        put casa_admin_path(casa_admin, format: :json), params: {
          casa_admin: {
            display_name: expected_display_name
          }
        }

        casa_admin.reload
        expect(response.content_type).to eq("application/json; charset=utf-8")
        expect(response).to have_http_status(:ok)
      end
    end

    context "when logged in as admin, but invalid data" do
      it "cannot update the casa admin", :aggregate_failures do
        casa_admin = create(:casa_admin)

        sign_in casa_admin
        put casa_admin_path(casa_admin), params: {
          casa_admin: {email: nil},
          phone_number: {phone_number: "dsadw323"}
        }

        casa_admin.reload
        expect(casa_admin.email).not_to eq nil
        expect(casa_admin.phone_number).not_to eq "dsadw323"
        expect(response).to render_template :edit
      end

      it "also respond as json", :aggregate_failures do
        casa_admin = create(:casa_admin)

        sign_in casa_admin
        put casa_admin_path(casa_admin, format: :json), params: {
          casa_admin: {email: nil}
        }

        expect(response.content_type).to eq("application/json; charset=utf-8")
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to match("Email can't be blank".to_json)
      end
    end

    context "logged in as a non-admin user" do
      it "cannot update a casa admin user" do
        sign_in_as_volunteer
        admin = create(:casa_admin)

        put casa_admin_path(admin), params: {
          casa_admin: {
            email: "admin@casa.com",
            display_name: "The admin"
          }
        }

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "unauthenticated request" do
      it "cannot update a casa admin user" do
        admin = create(:casa_admin)

        put casa_admin_path(admin), params: {
          casa_admin: {
            email: "admin@casa.com",
            display_name: "The admin"
          }
        }

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "PATCH /activate" do
    context "when successfully" do
      it "activates an inactive casa_admin" do
        casa_admin = create(:casa_admin)
        casa_admin_other = create(:casa_admin, active: false)

        sign_in casa_admin
        patch activate_casa_admin_path(casa_admin_other)

        casa_admin_other.reload
        expect(casa_admin_other).to be_active
      end

      it "sends an activation email" do
        casa_admin = create(:casa_admin)
        casa_admin_inactive = create(:casa_admin, active: false)

        sign_in casa_admin
        expect { patch activate_casa_admin_path(casa_admin_inactive) }
          .to change { ActionMailer::Base.deliveries.count }
          .by(1)
      end

      it "also respond as json", :aggregate_failures do
        casa_admin = create(:casa_admin)
        casa_admin_inactive = create(:casa_admin, active: false)

        sign_in casa_admin
        patch activate_casa_admin_path(casa_admin_inactive, format: :json)

        expect(response.content_type).to eq("application/json; charset=utf-8")
        expect(response).to have_http_status(:ok)
        expect(response.body).to match(casa_admin.reload.active.to_json)
      end
    end

    context "when occurs send errors" do
      it "redirects to admin edition page" do
        casa_admin = create(:casa_admin)
        casa_admin_inactive = create(:casa_admin, active: false)
        allow(CasaAdminMailer).to receive_message_chain(:account_setup, :deliver) { raise Errno::ECONNREFUSED }

        sign_in casa_admin
        patch activate_casa_admin_path(casa_admin_inactive)

        expect(response).to redirect_to(edit_casa_admin_path(casa_admin_inactive))
      end

      it "shows error message" do
        casa_admin = create(:casa_admin)
        casa_admin_inactive = create(:casa_admin, active: false)
        allow(CasaAdminMailer).to receive_message_chain(:account_setup, :deliver) { raise Errno::ECONNREFUSED }

        sign_in casa_admin
        patch activate_casa_admin_path(casa_admin_inactive)

        expect(flash[:alert]).to eq("Email not sent.")
      end

      it "also respond as json", :aggregate_failures do
        casa_admin = create(:casa_admin)
        casa_admin_inactive = create(:casa_admin, active: false)
        allow_any_instance_of(CasaAdmin).to receive(:activate).and_return(false)
        allow_any_instance_of(CasaAdmin).to receive_message_chain(:errors, :full_messages)
          .and_return ["Error message test"]

        sign_in casa_admin
        patch activate_casa_admin_path(casa_admin_inactive, format: :json)

        expect(response.content_type).to eq("application/json; charset=utf-8")
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to match("Error message test".to_json)
      end
    end
  end

  describe "PATCH /casa_admins/:id/deactivate" do
    context "logged in as admin user" do
      context "when successfully" do
        it "can successfully deactivate a casa admin user" do
          casa_admin = create(:casa_admin)
          casa_admin_other = create(:casa_admin, active: true)

          sign_in casa_admin
          patch deactivate_casa_admin_path(casa_admin_other)

          casa_admin_other.reload
          expect(casa_admin_other).to_not be_active

          expect(response).to redirect_to edit_casa_admin_path(casa_admin_other)
          expect(response.request.flash[:notice]).to eq "Admin was deactivated."
        end

        it "sends a deactivation email" do
          casa_admin = create(:casa_admin)
          casa_admin_active = create(:casa_admin, active: true)

          sign_in casa_admin
          expect { patch deactivate_casa_admin_path(casa_admin_active) }
            .to change { ActionMailer::Base.deliveries.count }
            .by(1)
        end

        it "also respond as json", :aggregate_failures do
          casa_admin = create(:casa_admin)
          casa_admin_active = create(:casa_admin, active: true)

          sign_in casa_admin
          patch deactivate_casa_admin_path(casa_admin_active, format: :json)

          expect(response.content_type).to eq("application/json; charset=utf-8")
          expect(response).to have_http_status(:ok)
          expect(response.body).to match(casa_admin.reload.active.to_json)
        end
      end

      context "when occurs send errors" do
        it "redirects to admin edit page" do
          casa_admin = create(:casa_admin)
          casa_admin_active = create(:casa_admin, active: true)
          allow(CasaAdminMailer).to receive_message_chain(:deactivation, :deliver) { raise Errno::ECONNREFUSED }

          sign_in casa_admin
          patch deactivate_casa_admin_path(casa_admin_active)

          expect(response).to redirect_to(edit_casa_admin_path(casa_admin_active))
        end

        it "shows error message" do
          casa_admin = create(:casa_admin)
          casa_admin_active = create(:casa_admin, active: true)
          allow(CasaAdminMailer).to receive_message_chain(:deactivation, :deliver) { raise Errno::ECONNREFUSED }

          sign_in casa_admin
          patch deactivate_casa_admin_path(casa_admin_active)

          expect(flash[:alert]).to eq("Email not sent.")
        end

        it "also respond as json", :aggregate_failures do
          casa_admin = create(:casa_admin)
          casa_admin_active = create(:casa_admin, active: true)
          allow_any_instance_of(CasaAdmin).to receive(:deactivate).and_return(false)
          allow_any_instance_of(CasaAdmin).to receive_message_chain(:errors, :full_messages)
            .and_return ["Error message test"]

          sign_in casa_admin
          patch deactivate_casa_admin_path(casa_admin_active, format: :json)

          expect(response.content_type).to eq("application/json; charset=utf-8")
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to match("Error message test".to_json)
        end
      end
    end

    context "logged in as a non-admin user" do
      it "cannot update a casa admin user" do
        admin = create(:casa_admin)

        sign_in_as_volunteer
        patch deactivate_casa_admin_path(admin)

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "unauthenticated request" do
      it "cannot update a casa admin user" do
        admin = create(:casa_admin)

        patch deactivate_casa_admin_path(admin)

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "PATCH /resend_invitation" do
    it "resends an invitation email" do
      casa_admin = create(:casa_admin, active: true)

      sign_in casa_admin
      expect(casa_admin.invitation_created_at.present?).to eq(false)

      patch resend_invitation_casa_admin_path(casa_admin)
      casa_admin.reload

      expect(casa_admin.invitation_created_at.present?).to eq(true)
      expect(Devise.mailer.deliveries.count).to eq(1)
      expect(Devise.mailer.deliveries.first.subject).to eq(I18n.t("devise.mailer.invitation_instructions.subject"))
      expect(response).to redirect_to(edit_casa_admin_path(casa_admin))
    end
  end

  describe "POST /casa_admins" do
    context "when successfully" do
      it "creates a new casa_admin" do
        org = create(:casa_org, twilio_enabled: true)
        admin = create(:casa_admin, casa_org: org)
        params = attributes_for(:casa_admin)

        sign_in admin

        expect {
          post casa_admins_path, params: {casa_admin: params}
        }.to change(CasaAdmin, :count).by(1)
        expect(response).to redirect_to casa_admins_path
        expect(flash[:notice]).to eq("New admin created successfully.")
      end

      it "also respond to json", :aggregate_failures do
        org = create(:casa_org, twilio_enabled: true)
        admin = create(:casa_admin, casa_org: org)
        params = attributes_for(:casa_admin)

        sign_in admin
        post casa_admins_path(format: :json), params: {casa_admin: params}

        expect(response.content_type).to eq("application/json; charset=utf-8")
        expect(response).to have_http_status(:created)
        expect(response.body).to match(params[:display_name].to_json)
      end
    end

    context "when creating new admin" do
      it "sends SMS when phone number is provided " do
        org = create(:casa_org, twilio_enabled: true)
        admin = create(:casa_admin, casa_org: org)
        twilio_activation_success_stub = WebMockHelper.twilio_activation_success_stub("admin")
        short_io_stub = WebMockHelper.short_io_stub_sms
        params = attributes_for(:casa_admin)
        params[:phone_number] = "+12222222222"

        sign_in admin
        post casa_admins_path, params: {casa_admin: params}

        expect(short_io_stub).to have_been_requested.times(2)
        expect(twilio_activation_success_stub).to have_been_requested.times(1)
        expect(response).to have_http_status(:redirect)
        follow_redirect!
        expect(flash[:notice]).to match(/New admin created successfully. SMS has been sent!/)
      end

      it "does not send SMS when phone number not given" do
        org = create(:casa_org, twilio_enabled: true)
        admin = create(:casa_admin, casa_org: org)
        twilio_activation_success_stub = WebMockHelper.twilio_activation_success_stub("admin")
        twilio_activation_error_stub = WebMockHelper.twilio_activation_error_stub("admin")
        short_io_stub = WebMockHelper.short_io_stub_sms
        params = attributes_for(:casa_admin)

        sign_in admin
        post casa_admins_path, params: {casa_admin: params}

        expect(short_io_stub).to have_been_requested.times(0)
        expect(twilio_activation_success_stub).to have_been_requested.times(0)
        expect(twilio_activation_error_stub).to have_been_requested.times(0)
        expect(response).to have_http_status(:redirect)
        follow_redirect!
        expect(flash[:notice]).to match(/New admin created successfully./)
      end

      it "does not send SMS when Twilio has an error" do
        org = create(:casa_org, twilio_account_sid: "articuno31", twilio_enabled: true)
        admin = build(:casa_admin, casa_org: org)
        short_io_stub = WebMockHelper.short_io_stub_sms
        twilio_activation_error_stub = WebMockHelper.twilio_activation_error_stub("admin")
        params = attributes_for(:casa_admin)
        params[:phone_number] = "+12222222222"

        sign_in admin
        post casa_admins_path, params: {casa_admin: params}

        expect(short_io_stub).to have_been_requested.times(2) # TODO: why is this called at all?
        expect(twilio_activation_error_stub).to have_been_requested.times(1)
        expect(response).to have_http_status(:redirect)
        follow_redirect!
        expect(flash[:notice]).to match(/New admin created successfully. SMS not sent. Error: ./)
      end

      it "does not send SMS when Twilio is not enabled" do
        org = create(:casa_org, twilio_enabled: false)
        admin = build(:casa_admin, casa_org: org)
        params = attributes_for(:casa_admin)
        params[:phone_number] = "+12222222222"
        short_io_stub = WebMockHelper.short_io_stub_sms

        sign_in admin
        post casa_admins_path, params: {casa_admin: params}

        expect(short_io_stub).to have_been_requested.times(2) # TODO: why is this called at all?
        expect(response).to have_http_status(:redirect)
        follow_redirect!
        expect(flash[:notice]).to match(/New admin created successfully./)
      end
    end

    context "when failure" do
      it "does not create a new casa_admin" do
        org = create(:casa_org, twilio_enabled: true)
        admin = create(:casa_admin, casa_org: org)
        allow_any_instance_of(CreateCasaAdminService).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
        params = attributes_for(:casa_admin)

        sign_in admin

        expect {
          post casa_admins_path, params: {casa_admin: params}
        }.not_to change(CasaAdmin, :count)
        expect(response).to render_template :new
      end

      it "also responds to json", :aggregate_failures do
        org = create(:casa_org, twilio_enabled: true)
        admin = create(:casa_admin, casa_org: org)

        sign_in admin
        casa_admin = instance_spy(CasaAdmin)
        allow(casa_admin).to receive_message_chain(:errors, :full_messages).and_return(["Some error message"])
        allow_any_instance_of(CreateCasaAdminService).to receive(:casa_admin).and_return(casa_admin)
        allow_any_instance_of(CreateCasaAdminService).to receive(:create!)
          .and_raise(ActiveRecord::RecordInvalid)
        params = attributes_for(:casa_admin)

        post casa_admins_path(format: :json), params: {casa_admin: params}

        expect(response.content_type).to eq("application/json; charset=utf-8")
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to match("Some error message".to_json)
      end
    end
  end

  describe "PATCH /change_to_supervisor" do
    context "when signed in as an admin" do
      it "changes the admin to a supervisor" do
        casa_admin = create(:casa_admin)

        sign_in_as_admin
        patch change_to_supervisor_casa_admin_path(casa_admin)

        expect(response).to redirect_to(edit_supervisor_path(casa_admin))

        # find the user after their type has changed
        user = User.find(casa_admin.id)
        expect(user).not_to be_casa_admin
        expect(user).to be_supervisor
      end
    end

    context "when signed in as a supervisor" do
      it "does not change the admin to a supervisor" do
        casa_admin = create(:casa_admin)
        supervisor = create(:supervisor)

        sign_in supervisor
        patch change_to_supervisor_casa_admin_path(casa_admin)

        casa_admin.reload
        expect(casa_admin).to be_casa_admin
        expect(casa_admin).not_to be_supervisor
      end
    end
  end
end
