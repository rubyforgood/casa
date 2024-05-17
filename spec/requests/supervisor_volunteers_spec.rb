require "rails_helper"

RSpec.describe "/supervisor_volunteers", type: :request do
  let!(:casa_org) { build(:casa_org) }
  let!(:admin) { build(:casa_admin, casa_org: casa_org) }
  let!(:supervisor) { create(:supervisor, casa_org: casa_org) }

  describe "POST /create" do
    let!(:volunteer) { create(:volunteer, casa_org: casa_org) }

    context "when no pre-existing association between supervisor and volunteer exists" do
      it "creates a new supervisor_volunteers association" do
        valid_parameters = {
          supervisor_volunteer: {volunteer_id: volunteer.id},
          supervisor_id: supervisor.id
        }
        sign_in(admin)

        expect {
          post supervisor_volunteers_url, params: valid_parameters, headers: {HTTP_REFERER: edit_volunteer_path(volunteer).to_s}
        }.to change(SupervisorVolunteer, :count).by(1)
        expect(response).to redirect_to edit_volunteer_path(volunteer)
      end
    end

    context "when an inactive association between supervisor and volunteer exists" do
      let!(:association) do
        create(
          :supervisor_volunteer,
          supervisor: supervisor,
          volunteer: volunteer,
          is_active: false
        )
      end

      it "sets that association to active" do
        valid_parameters = {
          supervisor_volunteer: {volunteer_id: volunteer.id},
          supervisor_id: supervisor.id
        }
        sign_in(admin)

        expect {
          post supervisor_volunteers_url, params: valid_parameters, headers: {HTTP_REFERER: edit_volunteer_path(volunteer).to_s}
        }.not_to change(SupervisorVolunteer, :count)
        expect(response).to redirect_to edit_volunteer_path(volunteer)

        association.reload
        expect(association.is_active?).to be(true)
      end
    end

    context "when an inactive association between the volunteer and a different supervisor exists" do
      let!(:other_supervisor) { build(:supervisor, casa_org: casa_org) }
      let!(:previous_association) do
        create(
          :supervisor_volunteer,
          supervisor: other_supervisor,
          volunteer: volunteer,
          is_active: false
        )
      end

      it "does not remove association" do
        valid_parameters = {
          supervisor_volunteer: {volunteer_id: volunteer.id},
          supervisor_id: supervisor.id
        }
        sign_in(admin)

        expect {
          post supervisor_volunteers_url, params: valid_parameters, headers: {HTTP_REFERER: edit_volunteer_path(volunteer).to_s}
        }.to change(SupervisorVolunteer, :count).by(1)
        expect(response).to redirect_to edit_volunteer_path(volunteer)

        expect(previous_association.reload.is_active?).to be(false)
        expect(SupervisorVolunteer.where(supervisor: supervisor, volunteer: volunteer).exists?).to be(true)
      end
    end

    context "when passing the supervisor_id as the supervisor_volunteer_params" do
      let!(:association) do
        create(
          :supervisor_volunteer,
          supervisor: supervisor,
          volunteer: volunteer,
          is_active: false
        )
      end

      it "will still set the association as active" do
        valid_parameters = {
          supervisor_volunteer: {supervisor_id: supervisor.id, volunteer_id: volunteer.id}
        }
        sign_in(admin)

        expect {
          post supervisor_volunteers_url, params: valid_parameters, headers: {HTTP_REFERER: edit_volunteer_path(volunteer).to_s}
        }.not_to change(SupervisorVolunteer, :count)
        expect(response).to redirect_to edit_volunteer_path(volunteer)

        association.reload
        expect(association.is_active?).to be(true)
      end
    end
  end

  describe "PATCH /unassign" do
    let!(:volunteer) { create(:volunteer, casa_org: casa_org) }
    let!(:association) do
      create(:supervisor_volunteer, supervisor: supervisor, volunteer: volunteer)
    end

    context "when the logged in user is an admin" do
      it "sets the is_active flag for assignment of a volunteer to a supervisor to false" do
        sign_in admin

        expect {
          patch unassign_supervisor_volunteer_path(volunteer), headers: {HTTP_REFERER: edit_volunteer_path(volunteer).to_s}
        }.to change(supervisor.volunteers, :count)

        association.reload
        expect(association.is_active?).to be(false)
        expect(response).to redirect_to edit_volunteer_path(volunteer)
      end
    end

    context "when the logged in user is a supervisor" do
      it "sets the is_active flag for assignment of a volunteer to a supervisor to false" do
        sign_in supervisor

        expect {
          patch unassign_supervisor_volunteer_path(volunteer), headers: {HTTP_REFERER: edit_volunteer_path(volunteer).to_s}
        }.to change(supervisor.volunteers, :count)

        association.reload

        expect(association.is_active?).to be(false)
        expect(response).to redirect_to edit_volunteer_path(volunteer)
      end
    end

    context "when the logged in user is not an admin or supervisor" do
      let!(:association) do
        create(:supervisor_volunteer, supervisor: supervisor, volunteer: volunteer)
      end

      it "does not set the is_active flag on the association to false" do
        sign_in volunteer

        expect {
          patch unassign_supervisor_volunteer_path(volunteer)
        }.not_to change(supervisor.volunteers, :count)

        association.reload

        expect(association.is_active?).to be(true)
      end
    end
  end

  describe "POST /bulk_assignment" do
    let!(:volunteer_1) { create(:volunteer, casa_org: casa_org) }
    let!(:volunteer_2) { create(:volunteer, casa_org: casa_org) }
    let!(:volunteer_3) { create(:volunteer, casa_org: casa_org) }
    let(:supervisor_id) { supervisor.id }
    let(:params) do
      {
        supervisor_volunteer: {
          supervisor_id: supervisor_id,
          volunteer_ids: [volunteer_1.id, volunteer_2.id, volunteer_3.id]
        }
      }
    end

    subject do
      post bulk_assignment_supervisor_volunteers_url, params: params
    end

    it "creates an association for each volunteer" do
      sign_in(admin)

      expect { subject }.to change(SupervisorVolunteer, :count).by(3)
    end

    context "when association already exists" do
      let!(:associations) do
        [
          create(:supervisor_volunteer, :inactive, supervisor: supervisor, volunteer: volunteer_1),
          create(:supervisor_volunteer, :inactive, supervisor: supervisor, volunteer: volunteer_2),
          create(:supervisor_volunteer, :inactive, supervisor: supervisor, volunteer: volunteer_3)
        ]
      end

      it "sets to active" do
        sign_in(admin)
        subject

        associations.each do |association|
          association.reload
          expect(association.is_active?).to be true
        end
      end

      it "does not create new associations" do
        sign_in(admin)

        expect { subject }.to change(SupervisorVolunteer, :count).by(0)
      end
    end

    context "when none passed as supervisor" do
      let(:supervisor_id) { "" }
      let!(:associations) do
        [
          create(:supervisor_volunteer, supervisor: supervisor, volunteer: volunteer_1),
          create(:supervisor_volunteer, supervisor: supervisor, volunteer: volunteer_2),
          create(:supervisor_volunteer, supervisor: supervisor, volunteer: volunteer_3)
        ]
      end

      it "sets associations to inactive" do
        sign_in(admin)
        subject

        associations.each do |association|
          association.reload
          expect(association.is_active?).to be false
        end
      end

      it "does not remove associations" do
        sign_in(admin)

        expect { subject }.to change(SupervisorVolunteer, :count).by(0)
      end
    end
  end
end
