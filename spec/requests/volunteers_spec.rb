require "rails_helper"
require "support/stubbed_requests/webmock_helper"

RSpec.describe "/volunteers", type: :request do
  let(:organization) { create(:casa_org) }
  let(:admin) { build(:casa_admin, casa_org: organization) }
  let(:supervisor) { create(:supervisor, casa_org: organization) }
  let(:volunteer) { create(:volunteer, casa_org: organization) }

  describe "GET /index" do
    it "renders a successful response" do
      sign_in admin

      get volunteers_path
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      sign_in admin

      get volunteer_path(volunteer.id)
      expect(response).to redirect_to(edit_volunteer_path(volunteer.id))
    end

    context "with admin from different organization" do
      let(:other_org_admin) { build(:casa_admin, casa_org: create(:casa_org)) }
      it "does not show" do
        sign_in other_org_admin
        get volunteer_path(volunteer.id)
        expect(response).to redirect_to("/")
      end
    end
  end

  describe "POST /datatable" do
    let(:data) { {recordsTotal: 51, recordsFiltered: 10, data: 10.times.map { {} }} }

    before do
      allow(VolunteerDatatable).to receive(:new).and_return double "datatable", as_json: data
    end

    it "is successful" do
      sign_in admin

      post datatable_volunteers_path
      expect(response).to be_successful
    end

    it "renders json data" do
      sign_in admin

      post datatable_volunteers_path
      expect(response.body).to eq data.to_json
    end
  end

  describe "GET /new" do
    it "renders a successful response for admin user" do
      sign_in admin

      get new_volunteer_path
      expect(response).to be_successful
    end

    it "renders a successful response for supervisor user" do
      sign_in supervisor

      get new_volunteer_path
      expect(response).to be_successful
    end

    it "does not render for volunteers" do
      sign_in volunteer

      get new_volunteer_path
      expect(response).to_not be_successful
    end
  end

  describe "GET /edit" do
    subject(:request) do
      get edit_volunteer_url(volunteer)

      response
    end

    before { sign_in admin }

    it { is_expected.to be_successful }

    it "shows correct volunteer", :aggregate_failures do
      create(:volunteer, casa_org: organization)

      page = request.parsed_body.to_html
      expect(page).to include(volunteer.email)
      expect(page).to include(volunteer.display_name)
      expect(page).to include(volunteer.phone_number)
    end

    it "shows correct supervisor options", :aggregate_failures do
      supervisors = create_list(:supervisor, 3, casa_org: organization)
      supervisors.append(create(:supervisor, casa_org: organization, display_name: "O'Hara")) # test for HTML escaping

      page = Nokogiri::HTML(subject.body)
      names = page.css("#supervisor_volunteer_supervisor_id option").map(&:text)
      expect(supervisors.map(&:display_name)).to match_array(names)
    end
  end

  describe "POST /create" do
    context "with valid params" do
      let(:params) do
        {
          volunteer: {
            display_name: "Example",
            email: "volunteer1@example.com"
          }
        }
      end

      it "creates a new volunteer and sends account_setup email" do
        organization = create(:casa_org)
        admin = create(:casa_admin, casa_org: organization)

        sign_in admin
        expect {
          post volunteers_url, params: params
        }.to change { ActionMailer::Base.deliveries.count }.by(1)

        expect(response).to have_http_status(:redirect)
        volunteer = Volunteer.last
        expect(volunteer.email).to eq("volunteer1@example.com")
        expect(volunteer.display_name).to eq("Example")
        expect(volunteer.casa_org).to eq(admin.casa_org)
        expect(response).to redirect_to edit_volunteer_path(volunteer)
      end

      it "sends a SMS when phone number exists" do
        organization = create(:casa_org, twilio_enabled: true)
        admin = create(:casa_admin, casa_org: organization)
        params[:volunteer][:phone_number] = "+12222222222"
        twilio_activation_success_stub = WebMockHelper.twilio_activation_success_stub("volunteer")
        short_io_stub = WebMockHelper.short_io_stub_sms

        sign_in admin
        post volunteers_url, params: params

        expect(short_io_stub).to have_been_requested.times(2)
        expect(twilio_activation_success_stub).to have_been_requested.times(1)
        expect(response).to have_http_status(:redirect)
        follow_redirect!
        expect(flash[:notice]).to match(/New volunteer created successfully. SMS has been sent!/)
      end

      it "does not send a SMS when phone number is not provided" do
        organization = create(:casa_org, twilio_enabled: true)
        admin = create(:casa_admin, casa_org: organization)
        sign_in admin
        post volunteers_url, params: params

        expect(response).to have_http_status(:redirect)
        follow_redirect!
        expect(flash[:notice]).to match(/New volunteer created successfully./)
      end

      it "does not send a SMS when Twilio API has an error" do
        org = create(:casa_org, twilio_account_sid: "articuno31", twilio_enabled: true)
        admin = create(:casa_admin, casa_org: org)
        twilio_activation_error_stub = WebMockHelper.twilio_activation_error_stub("volunteer")
        short_io_stub = WebMockHelper.short_io_stub_sms
        params[:volunteer][:phone_number] = "+12222222222"

        sign_in admin
        post volunteers_url, params: params

        expect(short_io_stub).to have_been_requested.times(2) # TODO: why is this called at all?
        expect(twilio_activation_error_stub).to have_been_requested.times(1)
        expect(response).to have_http_status(:redirect)
        follow_redirect!
        expect(flash[:notice]).to match(/New volunteer created successfully. SMS not sent. Error: ./)
      end

      it "does not send a SMS if the casa_org does not have Twilio enabled" do
        org = create(:casa_org, twilio_enabled: false)
        admin = build(:casa_admin, casa_org: org)
        params[:volunteer][:phone_number] = "+12222222222"
        short_io_stub = WebMockHelper.short_io_stub_sms

        sign_in admin
        post volunteers_url, params: params

        expect(short_io_stub).to have_been_requested.times(2) # TODO: why is this called at all?
        expect(response).to have_http_status(:redirect)
        follow_redirect!
        expect(flash[:notice]).to match(/New volunteer created successfully./)
      end
    end

    context "with invalid parameters" do
      let(:params) do
        {
          volunteer: {
            display_name: "",
            email: "volunteer1@example.com"
          }
        }
      end

      it "does not create a new volunteer" do
        org = create(:casa_org, twilio_enabled: false)
        admin = build(:casa_admin, casa_org: org)

        sign_in admin

        expect {
          post volunteers_url, params: params
        }.to change(Volunteer, :count).by(0)
          .and change(ActionMailer::Base.deliveries, :count).by(0)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH /update" do
    before { sign_in admin }

    context "with valid params" do
      it "updates the volunteer" do
        patch volunteer_path(volunteer), params: {
          volunteer: {display_name: "New Name", phone_number: "+15463457898"}
        }
        expect(response).to have_http_status(:redirect)

        volunteer.reload
        expect(volunteer.display_name).to eq "New Name"
        expect(volunteer.phone_number).to eq "15463457898"
      end

      it "sends the volunteer a confirmation email upon email change" do
        patch volunteer_path(volunteer), params: {
          volunteer: {email: "newemail@gmail.com"}
        }
        expect(response).to have_http_status(:redirect)

        volunteer.reload
        expect(volunteer.unconfirmed_email).to eq("newemail@gmail.com")
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(ActionMailer::Base.deliveries.first).to be_a(Mail::Message)
        expect(ActionMailer::Base.deliveries.first.body.encoded)
          .to match("You can confirm your account email through the link below:")
      end
    end

    context "with invalid params" do
      let!(:other_volunteer) { create(:volunteer) }

      it "does not update the volunteer" do
        volunteer.supervisor = build(:supervisor)

        patch volunteer_path(volunteer), params: {
          volunteer: {email: other_volunteer.email, display_name: "New Name", phone_number: "+15463457898"}
        }
        expect(response).to have_http_status(:success) # Re-renders form

        volunteer.reload
        expect(volunteer.display_name).to_not eq "New Name"
        expect(volunteer.email).to_not eq other_volunteer.email
        expect(volunteer.phone_number).to_not eq "+15463457898"
      end
    end

    # Activation/deactivation must be done separately through /activate and
    # /deactivate, respectively
    it "cannot change the active state" do
      patch volunteer_path(volunteer), params: {
        volunteer: {active: false}
      }
      volunteer.reload

      expect(volunteer.active).to eq(true)
    end
  end

  describe "PATCH /activate" do
    let(:volunteer) { create(:volunteer, :inactive, casa_org: organization) }
    let(:volunteer_with_cases) { create(:volunteer, :with_cases_and_contacts, casa_org: organization) }
    let(:case_number) { volunteer_with_cases.casa_cases.first.case_number.parameterize }

    it "activates an inactive volunteer" do
      sign_in admin

      patch activate_volunteer_path(volunteer)

      volunteer.reload
      expect(volunteer.active).to eq(true)
    end

    it "sends an activation email" do
      sign_in admin

      expect {
        patch activate_volunteer_path(volunteer)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    context "activated volunteer without cases" do
      it "shows a flash messages indicating the volunteer has been activated and sent an email" do
        sign_in admin

        patch activate_volunteer_path(volunteer)

        expect(response).to redirect_to(edit_volunteer_path(volunteer))
        follow_redirect!
        expect(flash[:notice]).to match(/Volunteer was activated. They have been sent an email./)
      end
    end

    context "activated volunteer with cases" do
      it "shows a flash message indicating the volunteer has been activated and sent an email" do
        sign_in admin

        patch activate_volunteer_path(id: volunteer_with_cases, redirect_to_path: "casa_case", casa_case_id: case_number)

        expect(response).to redirect_to(edit_casa_case_path(case_number))
        follow_redirect!
        expect(flash[:notice]).to match(/Volunteer was activated. They have been sent an email./)
      end
    end
  end

  describe "PATCH /deactivate" do
    subject(:request) do
      patch deactivate_volunteer_path(volunteer)

      response
    end

    before { sign_in admin }

    it { is_expected.to redirect_to(edit_volunteer_path(volunteer)) }

    it "shows the correct flash message" do
      request
      expect(flash[:notice]).to eq("Volunteer was deactivated.")
    end

    it "deactivates an active volunteer" do
      request
      expect(volunteer.reload.active).to eq(false)
    end

    it "doesn't send a deactivation email" do
      expect { request }.to_not change { ActionMailer::Base.deliveries.count }
    end
  end

  describe "PATCH /resend_invitation" do
    before { sign_in admin }
    it "resends an invitation email" do
      expect(volunteer.invitation_created_at.present?).to eq(false)

      get resend_invitation_volunteer_path(volunteer)
      volunteer.reload

      expect(volunteer.invitation_created_at.present?).to eq(true)
      expect(Devise.mailer.deliveries.count).to eq(1)
      expect(Devise.mailer.deliveries.first.subject).to eq(I18n.t("devise.mailer.invitation_instructions.subject"))
      expect(response).to redirect_to(edit_volunteer_path(volunteer))
    end
  end

  describe "POST /send_reactivation_alert" do
    before do
      sign_in admin
      @short_io_stub = WebMockHelper.twilio_activation_success_stub
    end

    it "sends an reactivation SMS" do
      get send_reactivation_alert_volunteer_path(volunteer)
      expect(response).to redirect_to(edit_volunteer_path(volunteer))
      expect(response.status).to match 302
    end

    it "does not send a reactivation SMS when Casa Org has Twilio disabled" do
      org = create(:casa_org, twilio_enabled: false)
      adm = create(:casa_admin, casa_org: org)
      vol = create(:volunteer, casa_org: org)

      sign_in adm

      get send_reactivation_alert_volunteer_path(vol)
      expect(response).to redirect_to(edit_volunteer_path(vol))
      expect(flash[:notice]).to match(/Volunteer reactivation alert not sent. Twilio is disabled for #{org.name}/)
    end
  end

  describe "GET /impersonate" do
    let!(:other_volunteer) { create(:volunteer, casa_org: organization) }
    let!(:supervisor) { create(:supervisor, casa_org: organization) }

    it "can impersonate a volunteer as an admin" do
      sign_in admin

      get impersonate_volunteer_path(volunteer)
      expect(response).to redirect_to(root_path)
      expect(controller.current_user).to eq(volunteer)
    end

    it "can impersonate a volunteer as a supervisor" do
      sign_in supervisor

      get impersonate_volunteer_path(volunteer)
      expect(response).to redirect_to(root_path)
      expect(controller.current_user).to eq(volunteer)
    end

    it "can not impersonate as a volunteer" do
      sign_in volunteer

      get impersonate_volunteer_path(other_volunteer)
      expect(response).to redirect_to(root_path)
      expect(controller.current_user).to eq(volunteer)

      follow_redirect!
      expect(flash[:notice]).to match(/Sorry, you are not authorized to perform this action./)
    end
  end
end
