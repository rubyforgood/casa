require "rails_helper"

RSpec.describe "CaseContacts::Forms", type: :request do
  let(:organization) { build(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:supervisor) { create(:supervisor, casa_org: organization) }
  let!(:volunteer) { create(:volunteer, casa_org: organization, supervisor: supervisor) }
  let(:creator) { admin }
  let!(:casa_case) { create(:casa_case, casa_org: organization) }

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
    subject(:request) do
      get case_contact_form_path(:details, case_contact_id: case_contact.id)

      response
    end

    describe "admin view" do
      before { sign_in admin }

      context "details step" do
        it "shows all contact types once" do
          page = request.parsed_body.to_html
          expected_contact_types = [].concat(contact_types_a, contact_types_b).map(&:name)
          expected_contact_types.each { |contact_type| expect(page.scan(contact_type).size).to eq(1) }
        end

        context "when the case has specific contact types assigned" do
          let!(:casa_case) { create(:casa_case, :with_casa_case_contact_types, casa_org: organization) }

          it "shows only contact types assigned to selected casa case" do
            page = request.parsed_body.to_html
            expect(page).to include(*casa_case.contact_types.pluck(:name))
            expect(page).not_to include(*contact_types_a.pluck(:name))
            expect(page).not_to include(*contact_types_b.pluck(:name))
          end
        end
        context "when an org has no topics" do
          let(:organization) { create(:casa_org) }
          let!(:case_contact) { create(:case_contact, :details_status, casa_case: casa_case) }

          it "it shows the admin the contact topics link" do
            page = request.parsed_body.to_html
            expect(page).to include("Manage Case Contact Topics</a> to set your organization Court report topics.")
          end
        end
        context "when the org has topics assigned" do
          let(:contact_topics) {
            [
              build(:contact_topic, active: true, soft_delete: false),
              build(:contact_topic, active: false, soft_delete: false),
              build(:contact_topic, active: true, soft_delete: true),
              build(:contact_topic, active: false, soft_delete: true)
            ]
          }
          let(:organization) { create(:casa_org, contact_topics:) }
          let!(:case_contact) { create(:case_contact, :details_status, :with_org_topics, casa_case: casa_case) }

          it "shows contact topics" do
            page = request.parsed_body.to_html
            expect(page).to include(contact_topics[0].question)
            expect(page).to_not include(contact_topics[1].question)
            expect(page).to_not include(contact_topics[2].question)
            expect(page).to_not include(contact_topics[3].question)
          end
        end
      end
    end
    describe "volunteer view" do
      before { sign_in volunteer }

      context "details step - when an org has no topics" do
        let(:organization) { create(:casa_org) }
        let!(:case_contact) { create(:case_contact, :details_status, casa_case:, creator: volunteer) }

        it "guides volunteer to contact admin" do
          page = request.parsed_body.to_html
          expect(page).to include("Your organization has not set any Court Report Topics yet. Contact your admin to learn more.")
        end
      end
    end
    describe "supervisor view" do
      before { sign_in supervisor }

      context "details step - when an org has no topics" do
        let(:organization) { create(:casa_org) }
        let!(:case_contact) { create(:case_contact, :details_status, casa_case:, creator: supervisor) }

        it "guides supervisor to contact admin" do
          page = request.parsed_body.to_html
          expect(page).to include("Your organization has not set any Court Report Topics yet. Contact your admin to learn more.")
        end
      end
    end
  end

  describe "PATCH /update" do
    before { sign_in admin }
    let!(:casa_case) { create(:casa_case, casa_org: organization) }
    let!(:case_contact) { create(:case_contact, :details_status, casa_case:) }
    let(:advance_form) { true }
    let(:params) { {case_contact: attributes} }

    subject(:request) do
      patch "/case_contacts/#{case_contact.id}/form/#{step}", params: params

      response
    end

    context "submitting details step" do
      let!(:case_contact) { create(:case_contact, :started_status, creator: creator, contact_topic_answers: topic_answers) }
      let(:topic_answers) { build_list(:contact_topic_answer, 3) }
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
            contact_type_ids: contact_type_ids,
            contact_topic_answers_attributes: topic_answers_attributes
          }
        end
        let(:contact_type_ids) do
          [contact_type_group_a.contact_types.first.id, contact_type_group_a.contact_types.second.id]
        end

        let(:topic_answers_attributes) do
          {
            "0" => {id: topic_answers.first.id, value: "test", selected: true},
            "1" => {id: topic_answers.second.id, value: "test", selected: true},
            "2" => {id: topic_answers.third.id, value: "test", selected: true}
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

        it "updates only answer field for contact topics" do
          request
          case_contact.reload

          expect(case_contact.contact_topic_answers.pluck(:value)).to be_all "test"
          expect(case_contact.contact_topic_answers.pluck(:selected)).to be_all true
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

    context "submitting notes step: contact topics" do
      let!(:case_contact) { create(:case_contact, :details_status, creator: creator, contact_topic_answers: topic_answers) }
      let(:topic_answers) { build_list(:contact_topic_answer, 3) }
      let(:topic_answers_attributes) do
        {
          "0" => {id: topic_answers.first.id, value: "test", selected: true},
          "1" => {id: topic_answers.second.id, value: "test", selected: true},
          "2" => {id: topic_answers.third.id, value: "test", selected: true}
        }
      end
      let(:step) { :notes }
      let(:attributes) do
        {contact_topic_answers_attributes: topic_answers_attributes}
      end

      context "with valid contact topic answers" do
        context "when submitting via button" do
          it "updates the requested case_contact" do
            request
            case_contact.reload

            expect(case_contact.contact_topic_answers.pluck(:value)).to be_all "test"
            expect(case_contact.contact_topic_answers.pluck(:selected)).to be_all true
          end
        end

        context "when autosaving" do
          subject(:request) do
            patch "/case_contacts/#{case_contact.id}/form/#{step}", params:, as: :json

            response
          end

          it "updates the requested case_contact" do
            request
            case_contact.reload

            expect(case_contact.contact_topic_answers.pluck(:value)).to be_all "test"
            expect(case_contact.contact_topic_answers.pluck(:selected)).to be_all true
          end

          it { is_expected.to have_http_status(:success) }
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
      let!(:case_contact) { create(:case_contact, :notes_status, draft_case_ids: [casa_case.id], creator: creator, contact_topic_answers: topic_answers) }
      let(:case_contact_topics) { build_list(:contact_topic_answer, 3) }
      let(:topic_answers) { build_list(:contact_topic_answer, 3) }
      let(:topic_answers_attributes) do
        {
          "0" => {id: topic_answers.first.id, value: "test", selected: true},
          "1" => {id: topic_answers.second.id, value: "test", selected: true},
          "2" => {id: topic_answers.third.id, value: "test", selected: true}
        }
      end
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
            additional_expenses_attributes: additional_expenses,
            contact_topic_answers_attributes: topic_answers_attributes
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
          expect(case_contact.contact_topic_answers.pluck(:value)).to be_all "test"
          expect(case_contact.contact_topic_answers.pluck(:selected)).to be_all true
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
          let!(:case_contact) {
            create(:case_contact, :notes_status, draft_case_ids: [casa_case.id, other_casa_case.id],
              creator: admin, contact_topic_answers: topic_answers)
          }

          it "creates a copy of the draft for each case" do
            expect {
              request
            }.to change(CaseContact, :count).by(1)
            expect(CaseContact.last.casa_case_id).to eq other_casa_case.id
            expect(CaseContact.last.draft_case_ids).to eq [other_casa_case.id]
            expect(CaseContact.last.status).to eq "active"
          end

          it "sets contact_topics for all cases" do
            expect { request }.to change(ContactTopicAnswer, :count).by(3)
            expect(CaseContact.last.contact_topic_answers.pluck(:value)).to be_all("test")
            expect(CaseContact.last.contact_topic_answers.pluck(:selected)).to be_all(true)
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
