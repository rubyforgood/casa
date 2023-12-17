require "rails_helper"

RSpec.describe "CaseContacts::Forms", type: :request do
  let(:organization) { build(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:supervisor) { create(:supervisor, casa_org: organization) }
  let(:volunteer) { create(:volunteer, casa_org: organization, supervisor: supervisor) }
  let(:creator) { admin }
  let!(:casa_case) { create(:casa_case, casa_org: organization) }

  before { sign_in admin }

  describe "GET /show" do
    let!(:case_contact) { create(:case_contact, :details_status, casa_case: casa_case) }
    let!(:contact_type_group_b) { create(:contact_type_group, casa_org: organization, name: "B") }
    let!(:contact_types_b) do
      [
        create(:contact_type, name: "Teacher", contact_type_group: contact_type_group_b),
        create(:contact_type, name: "Counselor", contact_type_group: contact_type_group_b)
      ]
    end

    let!(:contact_type_group_a) { create(:contact_type_group, casa_org: organization, name: "A") }
    let!(:contact_types_a) do
      [
        create(:contact_type, name: "Sibling", contact_type_group: contact_type_group_a),
        create(:contact_type, name: "Parent", contact_type_group: contact_type_group_a)
      ]
    end

    context "details step" do
      subject(:request) do
        get case_contact_form_path(:details, case_contact_id: case_contact.id)

        response
      end

      it "shows all contact types alphabetically by group" do
        page = request.parsed_body
        expected_contact_types = ["Parent", "Sibling", "Counselor", "Teacher"]
        expect(page).to match(/#{expected_contact_types.join(".*")}/m)
      end

      it "shows all contact types once" do
        page = request.parsed_body
        expected_contact_types = [].concat(contact_types_a, contact_types_b).map(&:name)
        expected_contact_types.each { |contact_type| expect(page.scan(contact_type).size).to eq(1) }
      end

      context "when the case has specific contact types assigned" do
        let!(:casa_case) { create(:casa_case, :with_casa_case_contact_types, casa_org: organization) }

        it "shows only contact types assigned to selected casa case" do
          page = request.parsed_body
          expect(page).to include(*casa_case.contact_types.pluck(:name))
          expect(page).not_to include(*contact_types_a.pluck(:name))
          expect(page).not_to include(*contact_types_b.pluck(:name))
        end
      end
    end
  end

  describe "PATCH /update" do
    let!(:casa_case) { create(:casa_case, casa_org: organization) }
    let(:advance_form) { true }
    let(:params) { {case_contact: attributes} }

    subject(:request) do
      patch "/case_contacts/#{case_contact.id}/form/#{step}", params: params

      response
    end

    context "submitting details step" do
      let!(:case_contact) { create(:case_contact, :started_status, creator: creator) }
      let(:step) { :details }
      let!(:contact_type_group_b) { create(:contact_type_group, casa_org: organization, name: "B") }
      let!(:contact_types_b) do
        [
          create(:contact_type, name: "Teacher", contact_type_group: contact_type_group_b),
          create(:contact_type, name: "Counselor", contact_type_group: contact_type_group_b)
        ]
      end

      let!(:contact_type_group_a) { create(:contact_type_group, casa_org: organization, name: "A") }
      let!(:contact_types_a) do
        [
          create(:contact_type, name: "Sibling", contact_type_group: contact_type_group_a),
          create(:contact_type, name: "Parent", contact_type_group: contact_type_group_a)
        ]
      end

      context "with valid attributes" do
        let(:attributes) do
          {
            draft_case_ids: [casa_case.id],
            occurred_at: 3.days.ago,
            duration_minutes: 50,
            contact_made: true,
            medium_type: CaseContact::CONTACT_MEDIUMS.second,
            case_contact_contact_type_attributes: contact_type_attributes
          }
        end
        let(:contact_type_attributes) do
          {
            "0" => {contact_type_id: contact_type_group_a.contact_types.first.id},
            "1" => {contact_type_id: contact_type_group_a.contact_types.second.id}
          }
        end

        it "with valid attributes updates the requested case_contact" do
          request
          case_contact.reload
          expect(case_contact.occurred_at).to eq(attributes[:occurred_at].floor)
          expect(case_contact.duration_minutes).to eq(50)
          expect(case_contact.contact_made).to eq(true)
          expect(case_contact.medium_type).to eq(CaseContact::CONTACT_MEDIUMS.second)
        end

        context "contact types" do
          it "attaches contact types" do
            request
            case_contact.reload
            expect(case_contact.contact_types.count).to eq 2
            expect(case_contact.contact_types.map(&:id)).to include(contact_type_group_a.contact_types.first.id)
            expect(case_contact.contact_types.map(&:id)).to include(contact_type_group_a.contact_types.second.id)
          end

          context "when updating contact types" do
            let(:old_contact_type) { create(:case_contact_contact_type, case_contact: case_contact, contact_type: contact_type_group_b.contact_types.first.id) }

            it "removes unselected ones" do
              expect(case_contact.contact_types.count).to eq 1
              expect(case_contact.contact_types.map(&:id)).not_to include(contact_type_group_a.contact_types.first.id)
              expect(case_contact.contact_types.map(&:id)).not_to include(contact_type_group_a.contact_types.second.id)

              request
              case_contact.reload
              expect(case_contact.contact_types.count).to eq 2
              expect(case_contact.contact_types.map(&:id)).to include(contact_type_group_a.contact_types.first.id)
              expect(case_contact.contact_types.map(&:id)).to include(contact_type_group_a.contact_types.second.id)
            end
          end
        end

        it { is_expected.to have_http_status(:redirect) }
      end

      context "with missing attributes" do
        let(:attributes) do
          {
            occurred_at: 3.days.ago,
            duration_minutes: 50,
            contact_made: true
          }
        end

        it "does not update the requested case_contact" do
          request
          expect(case_contact.duration_minutes).not_to eq(50)
          expect(case_contact.contact_made).not_to eq(true)
        end
      end
    end

    context "submitting notes step" do
      let!(:case_contact) { create(:case_contact, :details_status, creator: creator) }
      let(:step) { :notes }

      context "with valid attributes" do
        let(:attributes) do
          {
            notes: "This is a note."
          }
        end

        context "when submitting via button" do
          it "updates the requested case_contact" do
            request
            case_contact.reload
            expect(case_contact.notes).to eq "This is a note."
          end

          it "does not override other attributes" do
            request
            case_contact.reload
            expect(case_contact.duration_minutes).to eq 60
          end

          it { is_expected.to have_http_status(:redirect) }
        end

        context "when autosaving" do
          subject(:request) do
            patch "/case_contacts/#{case_contact.id}/form/#{step}", params: params, as: :json

            response
          end

          it "updates the requested case_contact" do
            request
            case_contact.reload
            expect(case_contact.notes).to eq "This is a note."
          end

          it "does not override other attributes" do
            request
            case_contact.reload
            expect(case_contact.duration_minutes).to eq 60
          end

          it { is_expected.to have_http_status(:success) }
        end
      end
    end

    context "submitting expenses step" do
      let!(:case_contact) { create(:case_contact, :notes_status, draft_case_ids: [casa_case.id], creator: creator) }
      let(:additional_expenses) do
        {
          "0" => {other_expense_amount: 50, other_expenses_describe: "meal"},
          "1" => {other_expense_amount: 100, other_expenses_describe: "hotel"}
        }
      end
      let(:step) { :expenses }

      context "with valid attributes" do
        let(:attributes) do
          {
            want_driving_reimbursement: true,
            miles_driven: 60,
            volunteer_address: "123 str",
            additional_expenses_attributes: additional_expenses
          }
        end

        it "updates the requested case_contact" do
          request
          case_contact.reload
          expect(case_contact.want_driving_reimbursement).to be_truthy
          expect(case_contact.miles_driven).to eq 60
          expect(case_contact.volunteer_address).to eq "123 str"
          expect(case_contact.additional_expenses.count).to eq 2
          expect(case_contact.additional_expenses.first.other_expense_amount).to eq 50
          expect(case_contact.additional_expenses.first.other_expenses_describe).to eq "meal"
          expect(case_contact.additional_expenses.last.other_expense_amount).to eq 100
          expect(case_contact.additional_expenses.last.other_expenses_describe).to eq "hotel"
        end

        it "sets the case_contact's status to active" do
          request
          case_contact.reload
          expect(case_contact.status).to eq "active"
        end

        it "sets the casa_case_id" do
          expect(case_contact.casa_case_id).to be_nil
          request
          case_contact.reload
          expect(case_contact.casa_case_id).to eq casa_case.id
        end

        context "with only one volunteer for the first case" do
          let!(:case_assignment) { create(:case_assignment, casa_case: casa_case, volunteer: volunteer) }

          it "updates the volunteer's address" do
            request
            expect(volunteer.address.content).to eq "123 str"
          end
        end

        context "with volunteer submitting" do
          let(:creator) { volunteer }

          it "updates the volunteer's address" do
            request
            expect(volunteer.address.content).to eq "123 str"
          end

          it "sends reimbursement email" do
            expect {
              request
            }.to change { have_enqueued_job(ActionMailer::MailDeliveryJob).with("SupervisorMailer", "reimbursement_request_email", volunteer, supervisor) }
          end
        end

        it { is_expected.to have_http_status(:redirect) }

        context "with multiple cases selected" do
          let!(:other_casa_case) { create(:casa_case, casa_org: organization) }
          let!(:case_contact) { create(:case_contact, :notes_status, draft_case_ids: [casa_case.id, other_casa_case.id], creator: admin) }

          it "creates a copy of the draft for each case" do
            expect {
              request
            }.to change(CaseContact, :count).by(1)
            expect(CaseContact.last.casa_case_id).to eq other_casa_case.id
            expect(CaseContact.last.draft_case_ids).to eq [other_casa_case.id]
            expect(CaseContact.last.status).to eq "active"
          end

          it "sets the draft_case_ids of the draft to only the first case" do
            expect(case_contact.draft_case_ids.count).to eq 2
            request
            case_contact.reload
            expect(case_contact.draft_case_ids.count).to eq 1
            expect(case_contact.draft_case_ids).to eq [casa_case.id]
          end
        end
      end
    end
  end
end
