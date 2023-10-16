require "rails_helper"

RSpec.describe "/case_assignments", type: :request do
  let(:casa_org) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: casa_org) }
  let(:volunteer) { create(:volunteer, casa_org: casa_org) }
  let(:casa_case) { create(:casa_case, casa_org: casa_org) }

  describe "POST /create" do
    before { sign_in admin }

    it "authorizes action" do
      expect_any_instance_of(CaseAssignmentsController).to receive(:authorize).with(CaseAssignment).and_call_original
      post case_assignments_url(volunteer_id: volunteer.id), params: {case_assignment: {casa_case_id: casa_case.id}}
    end

    context "when the volunteer has been previously assigned to the casa_case" do
      let!(:case_assignment) { create(:case_assignment, active: false, volunteer: volunteer, casa_case: casa_case) }
      let(:params) { {case_assignment: {volunteer_id: volunteer.id}} }

      subject(:request) do
        post case_assignments_url(casa_case_id: casa_case.id), params: params

        response
      end

      it "reassigns the volunteer to the casa_case" do
        expect { request }.to change { casa_case.case_assignments.first.active }.from(false).to(true)
      end

      it { is_expected.to redirect_to edit_casa_case_path(casa_case) }

      it "sets flash message correctly" do
        request
        expect(flash.notice).to eq "Volunteer reassigned to case"
      end

      context "when missing params" do
        let(:params) { {case_assignment: {volunteer_id: ""}} }

        it { is_expected.to redirect_to edit_casa_case_path(casa_case) }

        it "sets flash message correctly" do
          request
          expect(flash.alert).to match(/Unable to assign volunteer to case/)
        end
      end
    end

    context "when the case assignment parent is a volunteer" do
      let(:params) { {case_assignment: {casa_case_id: casa_case.id}} }

      subject(:request) do
        post case_assignments_url(volunteer_id: volunteer.id), params: params

        response
      end

      it "creates a new case assignment for the volunteer" do
        expect { request }.to change(volunteer.casa_cases, :count).by(1)
      end

      it { is_expected.to redirect_to edit_volunteer_path(volunteer) }

      it "sets flash message correctly" do
        request
        expect(flash.notice).to eq "Volunteer assigned to case"
      end

      context "when missing params" do
        let(:params) { {case_assignment: {volunteer_id: ""}} }

        it { is_expected.to redirect_to edit_volunteer_path(volunteer) }

        it "sets flash message correctly" do
          request
          expect(flash.alert).to match(/Unable to assign volunteer to case/)
        end
      end
    end

    context "when the case assignment parent is a casa_case" do
      let(:params) { {case_assignment: {volunteer_id: volunteer.id}} }

      subject(:request) do
        post case_assignments_url(casa_case_id: casa_case.id), params: params

        response
      end

      it "creates a new case assignment for the casa_case" do
        expect { request }.to change(casa_case.volunteers, :count).by(1)
      end

      it { is_expected.to redirect_to edit_casa_case_path(casa_case) }

      it "sets flash message correctly" do
        request
        expect(flash.notice).to eq "Volunteer assigned to case"
      end

      context "when missing params" do
        let(:params) { {case_assignment: {volunteer_id: ""}} }

        it { is_expected.to redirect_to edit_casa_case_path(casa_case) }

        it "sets flash message correctly" do
          request
          expect(flash.alert).to match(/Unable to assign volunteer to case/)
        end
      end
    end

    describe "with another org params" do
      let(:other_org) { build(:casa_org) }

      subject(:request) do
        post url, params: params

        response
      end

      context "when the case belongs to another organization" do
        let(:other_casa_case) { create(:casa_case, casa_org: other_org) }
        let(:url) { case_assignments_url(casa_case_id: other_casa_case.id) }
        let(:params) { {case_assignment: {volunteer_id: volunteer.id}} }

        it "does not create a case assignment" do
          expect { request }.not_to change(other_casa_case.volunteers, :count)
        end
      end

      context "when the volunteer belongs to another organization" do
        let(:other_volunteer) { build_stubbed(:volunteer, casa_org: other_org) }
        let(:url) { case_assignments_url(casa_case_id: casa_case.id) }
        let(:params) { {case_assignment: {volunteer_id: other_volunteer.id}} }

        it "does not create a case assignment" do
          expect { request }.not_to change(casa_case.volunteers, :count)
        end
      end
    end
  end

  describe "DELETE /destroy" do
    before { sign_in admin }

    let!(:assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }

    it "authorizes action" do
      expect_any_instance_of(CaseAssignmentsController).to receive(:authorize).with(assignment).and_call_original
      delete case_assignment_url(assignment, volunteer_id: volunteer.id)
    end

    context "when the case assignment parent is a volunteer" do
      subject(:request) do
        delete case_assignment_url(assignment, volunteer_id: volunteer.id)

        response
      end

      it "destroys the case assignment from the volunteer" do
        expect { request }.to change(volunteer.casa_cases, :count).by(-1)
      end

      it { is_expected.to redirect_to edit_volunteer_path(volunteer) }
    end

    context "when the case assignment parent is a casa_case" do
      subject(:request) do
        delete case_assignment_url(assignment, casa_case_id: casa_case.id)

        response
      end

      it "destroys the case assignment from the casa_case" do
        expect { request }.to change(casa_case.volunteers, :count).by(-1)
      end

      it { is_expected.to redirect_to edit_casa_case_path(casa_case) }
    end

    context "when the case belongs to another organization" do
      let(:other_org) { build(:casa_org) }
      let(:other_casa_case) { create(:casa_case, casa_org: other_org) }
      let!(:assignment) { create(:case_assignment, casa_case: other_casa_case) }

      subject(:request) do
        delete case_assignment_url(assignment, casa_case_id: other_casa_case.id)

        response
      end

      it "does not destroy the case assignment" do
        expect { request }.not_to change(other_casa_case.volunteers, :count).from(1)
      end

      it { is_expected.to be_not_found }
    end
  end

  describe "PATCH /unassign" do
    before { sign_in admin }

    let(:assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }
    let(:redirect_to_path) { "" }

    subject(:request) do
      patch unassign_case_assignment_url(assignment, redirect_to_path: redirect_to_path)

      response
    end

    it "authorizes action" do
      expect_any_instance_of(CaseAssignmentsController).to(
        receive(:authorize).with(assignment, :unassign?).and_call_original
      )
      request
    end

    it "deactivates the case assignment" do
      expect { request }.to change { assignment.reload.active? }.to(false)
    end

    it { is_expected.to redirect_to edit_casa_case_path(casa_case) }

    it "sets flash message correctly" do
      request
      expect(flash.notice).to eq "Volunteer was unassigned from Case #{casa_case.case_number}."
    end

    context "when request format is json" do
      subject(:request) do
        patch unassign_case_assignment_url(assignment, format: :json)

        response
      end

      it "sets body message correctly" do
        response_body = request.body
        expect(response_body).to eq "Volunteer was unassigned from Case #{casa_case.case_number}."
      end
    end

    context "when redirect_to_path is volunteer" do
      let(:redirect_to_path) { "volunteer" }

      it { is_expected.to redirect_to edit_volunteer_path(volunteer) }
    end

    context "when assignment belongs to another organization" do
      let(:other_org) { build(:casa_org) }
      let(:other_casa_case) { create(:casa_case, casa_org: other_org) }
      let(:assignment) { create(:case_assignment, casa_case: other_casa_case) }

      it "does not deactivate the case assignment" do
        expect { request }.not_to change { assignment.reload.active? }
      end
    end
  end

  describe "PATCH /show_hide_contacts" do
    before { sign_in admin }

    let(:assignment) { create(:case_assignment, casa_case: casa_case, volunteer: volunteer, active: false) }

    subject(:request) do
      patch show_hide_contacts_case_assignment_path(assignment)

      response
    end

    it "authorizes action" do
      expect_any_instance_of(CaseAssignmentsController).to(
        receive(:authorize).with(assignment, :show_or_hide_contacts?).and_call_original
      )
      request
    end

    context "when case contacts are visible" do
      it "toggles to hide case contacts" do
        expect { request }.to change { assignment.reload.hide_old_contacts? }
      end

      it { is_expected.to redirect_to edit_casa_case_path(casa_case) }

      it "sets flash message correctly" do
        request
        expect(flash.notice).to eq "Old Case Contacts created by #{volunteer.display_name} were successfully hidden."
      end
    end

    context "when case contacts are hidden" do
      let(:assignment) do
        create(:case_assignment, casa_case: casa_case, volunteer: volunteer, active: false, hide_old_contacts: true)
      end

      it "toggles to show case contacts" do
        expect { request }.to change { assignment.reload.hide_old_contacts? }
      end

      it { is_expected.to redirect_to edit_casa_case_path(casa_case) }

      it "sets flash message correctly" do
        request
        expect(flash.notice).to eq "Old Case Contacts created by #{volunteer.display_name} are now visible."
      end
    end

    context "when the case_assignment is active" do
      let(:assignment) { create(:case_assignment, casa_case: casa_case, volunteer: volunteer, active: true) }

      xit "does not toggle contacts visibility" do
        # TODO: fix controller as it is trying to render a template that does not exist
        expect { request }.not_to change { assignment.reload.hide_old_contacts? }
      end

      xit "renders the edit page?" do
        # TODO: fix controller as it is trying to render a template that does not exist
      end
    end
  end

  describe "PATCH /reimbursement" do
    before { sign_in admin }

    let(:assignment) { create(:case_assignment, casa_case: casa_case, volunteer: volunteer) }

    subject(:request) do
      patch reimbursement_case_assignment_url(assignment)

      response
    end

    it "authorizes action" do
      expect_any_instance_of(CaseAssignmentsController).to(
        receive(:authorize).with(assignment, :reimbursement?).and_call_original
      )
      request
    end

    it "toggles allow_reimbursement" do
      expect { request }.to change { assignment.reload.allow_reimbursement }
    end

    it { is_expected.to redirect_to edit_casa_case_path(casa_case) }

    it "sets flash message correctly" do
      request
      expect(flash.notice).to eq "Volunteer allow reimbursement changed from Case #{casa_case.case_number}."
    end
  end
end
