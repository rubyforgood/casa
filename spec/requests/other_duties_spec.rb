require "rails_helper"

RSpec.describe "/other_duties", type: :request do
  describe "GET /new" do
    context "when volunteer" do
      it "is successful" do
        volunteer = create(:volunteer)

        sign_in volunteer
        get new_other_duty_path

        expect(response).to be_successful
      end
    end

    context "when supervisor" do
      it "redirects to root path" do
        supervisor = create(:supervisor)

        sign_in supervisor
        get new_other_duty_path

        expect(response).to redirect_to root_path
      end
    end

    context "when admin" do
      it "redirects to root path" do
        admin = create(:casa_admin)

        sign_in admin
        get new_other_duty_path

        expect(response).to redirect_to root_path
      end
    end
  end

  describe "POST /create" do
    context "when volunteer" do
      context "with valid parameters" do
        it "creates one new Duty and returns to casa_cases page" do
          volunteer = create(:volunteer)

          sign_in volunteer

          expect {
            post other_duties_path, params: {other_duty: attributes_for(:other_duty)}
          }.to change(OtherDuty, :count).by(1)
          expect(response).to redirect_to(casa_cases_path)
        end
      end

      context "with invalid parameters" do
        it "does not create a new Duty and renders new page" do
          volunteer = create(:volunteer)

          sign_in volunteer

          expect {
            post other_duties_path, params: {other_duty: attributes_for(:other_duty, notes: "")}
          }.to_not change(OtherDuty, :count)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when supervisor" do
      it "does not create record and redirects to root" do
        supervisor = create(:supervisor)

        sign_in supervisor

        expect {
          post other_duties_path, params: {other_duty: attributes_for(:other_duty)}
        }.to_not change(OtherDuty, :count)

        expect(response).to redirect_to root_path
      end
    end

    context "when admin" do
      it "does not create record and redirects to root" do
        admin = create(:casa_admin)

        sign_in admin

        expect {
          post other_duties_path, params: {other_duty: attributes_for(:other_duty)}
        }.to_not change(OtherDuty, :count)

        expect(response).to redirect_to root_path
      end
    end
  end

  describe "GET /edit" do
    context "when volunteer" do
      context "when viewing own record" do
        it "is successful" do
          volunteer = create(:volunteer)
          duty = create(:other_duty, creator: volunteer)

          sign_in volunteer
          get edit_other_duty_path(duty)

          expect(response).to be_successful
        end
      end

      context "when viewing other's record" do
        it "redirects to root path" do
          volunteer = create(:volunteer)
          duty = create(:other_duty)

          sign_in volunteer
          get edit_other_duty_path(duty)

          expect(response).to redirect_to root_path
        end
      end
    end

    context "when supervisor" do
      it "redirects to root path" do
        supervisor = create(:supervisor)
        duty = create(:other_duty)

        sign_in supervisor
        get edit_other_duty_path(duty)

        expect(response).to redirect_to root_path
      end
    end

    context "when admin" do
      it "redirects to root path" do
        admin = create(:casa_admin)
        duty = create(:other_duty)

        sign_in admin
        get edit_other_duty_path(duty)

        expect(response).to redirect_to root_path
      end
    end
  end

  describe "PATCH /update" do
    context "when volunteer updating own duty" do
      context "with valid parameters" do
        it "updates the duty and redirects to casa_cases page" do
          volunteer = create(:volunteer)
          other_duty = create(:other_duty, notes: "Test 1", creator: volunteer)

          sign_in volunteer
          patch other_duty_path(other_duty), params: {other_duty: {notes: "Test 2"}}

          expect(other_duty.reload.notes).to eq("Test 2")
          expect(response).to redirect_to casa_cases_path
        end
      end

      context "with invalid parameters" do
        it "does not update and re-renders edit page" do
          volunteer = create(:volunteer)
          other_duty = create(:other_duty, notes: "Test 1", creator: volunteer)

          sign_in volunteer
          patch other_duty_path(other_duty), params: {other_duty: {notes: ""}}

          expect(other_duty.reload.notes).to eq "Test 1"
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when volunteer updating other person's record" do
      it "does not update the duty and redirects to root path" do
        volunteer = create(:volunteer)
        other_duty = create(:other_duty, notes: "Test 1")

        sign_in volunteer
        patch other_duty_path(other_duty), params: {other_duty: {notes: "Test 2"}}

        expect(other_duty.reload.notes).to eq("Test 1")
        expect(response).to redirect_to root_path
      end
    end

    context "when supervisor" do
      it "does not update the duty and redirects to root path" do
        supervisor = create(:supervisor)
        other_duty = create(:other_duty, notes: "Test 1")

        sign_in supervisor
        patch other_duty_path(other_duty), params: {other_duty: {notes: "Test 2"}}

        expect(other_duty.reload.notes).to eq("Test 1")
        expect(response).to redirect_to root_path
      end
    end

    context "when admin" do
      it "does not update the duty and redirects to root path" do
        admin = create(:casa_admin)
        other_duty = create(:other_duty, notes: "Test 1")

        sign_in admin
        patch other_duty_path(other_duty), params: {other_duty: {notes: "Test 2"}}

        expect(other_duty.reload.notes).to eq("Test 1")
        expect(response).to redirect_to root_path
      end
    end
  end

  describe "GET /index" do
    context "when admin" do
      it "can see volunteer's other duties from own organization" do
        volunteer = create(:volunteer)
        duties = create_pair(:other_duty, creator: volunteer)
        admin = create(:casa_admin, casa_org: volunteer.casa_org)
        other_org_duty = create(:other_duty)

        sign_in admin
        get other_duties_path

        expect(response.body).to include(volunteer.display_name)
        expect(response.body).to include(duties.first.decorate.truncate_notes)
        expect(response.body).to include(duties.second.decorate.truncate_notes)
        expect(response.body).to_not include(other_org_duty.decorate.truncate_notes)
      end
    end

    context "when supervisor" do
      it "can see own active volunteer's other duties from own organization" do
        supervisor = create(:supervisor, :with_volunteers)
        volunteer1 = supervisor.volunteers.first
        volunteer2 = supervisor.volunteers.last
        SupervisorVolunteer.find_by(supervisor: supervisor, volunteer: volunteer2).update!(is_active: false)
        duties = create_pair(:other_duty, creator: volunteer1)
        inactive_duty = create(:other_duty, creator: volunteer2)

        volunteer_other_sup = create(:volunteer, casa_org: volunteer1.casa_org)
        other_sup_duty = create(:other_duty, creator: volunteer_other_sup)

        other_org = create(:casa_org)
        volunteer_other_org = create(:volunteer, casa_org: other_org)
        other_org_duty = create(:other_duty, creator: volunteer_other_org)

        sign_in supervisor
        get other_duties_path

        expect(response.body).to include(volunteer1.display_name)
        expect(response.body).to include(duties.first.decorate.truncate_notes)
        expect(response.body).to include(duties.second.decorate.truncate_notes)

        expect(response.body).to_not include(volunteer2.display_name)
        expect(response.body).to_not include(inactive_duty.decorate.truncate_notes)

        expect(response.body).to_not include(volunteer_other_sup.display_name)
        expect(response.body).to_not include(other_sup_duty.decorate.truncate_notes)

        expect(response.body).to_not include(volunteer_other_org.display_name)
        expect(response.body).to_not include(other_org_duty.decorate.truncate_notes)
      end
    end

    context "when volunteer" do
      it "redirects to root path" do
        volunteer = create(:volunteer)

        sign_in volunteer
        get other_duties_path

        expect(response).to redirect_to root_path
      end
    end
  end
end
