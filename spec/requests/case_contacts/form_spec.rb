require "rails_helper"

RSpec.describe "CaseContacts::Forms", type: :request do
  let(:casa_org) { build(:casa_org) }
  let(:contact_topics) { create_list(:contact_topic, 3, casa_org:) }
  let(:casa_admin) { create(:casa_admin, casa_org:) }
  let(:supervisor) { create(:supervisor, casa_org:) }
  let(:volunteer) { create(:volunteer, :with_single_case, casa_org:, supervisor: supervisor) }
  let(:creator) { volunteer }
  let(:casa_case) { volunteer.casa_cases.first }

  let(:user) { volunteer }

  before { sign_in user }

  describe "GET /new" do
    subject(:request) { get new_case_contact_path(casa_case_id: casa_case.id) }

    it "creates a new case_contact record with user as creator and status 'started'" do
      expect { request }.to change(CaseContact, :count).by(1)
      case_contact = CaseContact.last
      expect(case_contact.status).to eq "started"
      expect(case_contact.creator).to eq user
    end

    it "does not set the contact's casa_case_id" do
      expect { request }.to change(CaseContact, :count).by(1)
      case_contact = CaseContact.last
      expect(case_contact.casa_case_id).to be_nil
    end

    it "redirects to show(:details) with the created contact id" do
      expect { request }.to change(CaseContact, :count).by(1)
      case_contact = CaseContact.last
      expect(request).to redirect_to(case_contact_form_path(:details, case_contact_id: case_contact.id))
    end
  end

  describe "GET /show" do
    let(:case_contact) { create(:case_contact, :started_status, casa_case:, creator:) }

    subject(:request) { get case_contact_form_path(:details, case_contact_id: case_contact.id) }

    it "renders details form with success status" do
      request

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:details)
    end

    it "does not change status from 'started'" do
      expect(case_contact.status).to eq "started"
      request

      expect(response).to have_http_status(:success)
      expect(case_contact.reload.status).to eq "started"
    end

    context "when contact created by another casa org volunteer" do
      let(:other_volunteer) { create(:volunteer, casa_org:) }
      let(:creator) { other_volunteer }
      let!(:case_assignment) { create(:case_assignment, volunteer: other_volunteer, casa_case:) }

      it "redirects to root/sign in" do
        expect(casa_case.volunteers).to include(volunteer, other_volunteer)
        expect(case_contact.creator).to eq other_volunteer
        request

        expect(response).to redirect_to(root_path)
      end
    end

    context "when user is supervisor" do
      let(:user) { supervisor }

      it "does not permit volunteer's supervisor to view the form" do
        expect(supervisor.volunteers).to include(volunteer)
        expect(casa_case.volunteers).to include(volunteer)
        expect(case_contact.creator).to eq volunteer
        request

        expect(response).to redirect_to(root_path)
      end
    end

    context "when user is casa admin" do
      let(:user) { casa_admin }

      it "allows admin to view the form" do
        expect(casa_case.volunteers).to include(volunteer)
        expect(case_contact.creator).to eq volunteer
        request

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:details)
      end
    end

    context "when step is not :details" do
      subject(:request) { get case_contact_form_path(:notes, case_contact_id: case_contact.id) }

      it "raises Wicked::Wizard::InvalidStepError" do
        expect { request }.to raise_error(Wicked::Wizard::InvalidStepError)
      end
    end
  end

  describe "PATCH /update" do
    let(:case_contact) { create(:case_contact, :started_status, creator: volunteer) }
    let(:contact_type_group) { create(:contact_type_group, casa_org:) }
    let!(:contact_types) { create_list(:contact_type, 2, contact_type_group:) }
    let(:medium_type) { CaseContact::CONTACT_MEDIUMS.second }
    let(:contact_type_ids) { [contact_types.first.id] }
    let(:draft_case_ids) { [casa_case.id] }

    let(:required_attributes) do
      {
        draft_case_ids: draft_case_ids.map(&:to_s),
        occurred_at: 3.days.ago.to_date, # iso format
        medium_type:
      }
    end
    let(:valid_attributes) do
      required_attributes.merge({
        contact_type_ids: contact_type_ids.map(&:to_s),
        contact_made: "1",
        duration_minutes: 50,
        duration_hours: 1
      })
    end
    let(:invalid_attributes) do
      {occurred_at: 3.days.from_now, duration_minutes: 50, contact_made: true}
    end
    let(:attributes) { valid_attributes }
    let(:params) { {case_contact: attributes} }

    subject(:request) { patch "/case_contacts/#{case_contact.id}/form/details", params: params }

    it "updates the requested case_contact attributes" do
      case_contact.update!(duration_minutes: 5, contact_made: false, contact_type_ids: [contact_types.second.id])
      submitted_hours = attributes[:duration_hours]
      submitted_minutes = attributes[:duration_minutes]
      submitted_minutes += (60 * submitted_hours) if submitted_hours
      request

      case_contact.reload
      expect(case_contact.contact_type_ids).to contain_exactly(contact_types.first.id)
      expect(case_contact.contact_made).to be true
      expect(case_contact.duration_minutes).to eq submitted_minutes
    end

    it "updates the requested contact_type_ids" do
      expect(case_contact.contact_types).not_to include(contact_types.first)
      request

      case_contact.reload
      expect(case_contact.contact_types).to contain_exactly(contact_types.first)
      expect(case_contact.contact_types.size).to eq 1
    end

    it "sets the case_contact's casa_case_id and status: 'active'" do
      expect(case_contact.casa_case_id).to be_nil
      expect(case_contact.status).to eq "started"
      request

      case_contact.reload
      expect(case_contact.status).to eq "active"
      expect(case_contact.casa_case_id).to eq casa_case.id
    end

    it "changes status to 'active' if it was 'started'" do
      case_contact.update!(status: "started")
      request
      expect(case_contact.reload.status).to eq "active"
    end

    it "raises RoutingError if no step in url" do
      expect { patch "/case_contacts/#{case_contact.id}/form", params: {case_contact: attributes} }
        .to raise_error(ActionController::RoutingError)
    end

    it "redirects to referrer (fallback /case_contacts?success=true)" do
      request
      expect(response).to have_http_status :redirect
      expect(response).to redirect_to case_contacts_path(success: true)
    end

    context "with invalid attributes" do
      let(:attributes) { invalid_attributes }

      it "does not update the requested case_contact" do
        original_attributes = case_contact.attributes
        request

        expect(case_contact.reload).to have_attributes original_attributes
        expect(case_contact.duration_minutes).not_to eq(50)
        expect(case_contact.contact_made).not_to be(true)
      end

      it "re-renders the form" do
        request

        # this should be a different status, but wicked wizard's 'render' method is a bit different?
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:details)
      end

      it "does not change the contact status from 'started'" do
        case_contact.started!
        expect { request }.not_to change(case_contact, :status)
        expect(case_contact.reload.status).to eq "started"
      end
    end

    context "when contact types were previously assigned" do
      before { case_contact.update!(contact_type_ids: [contact_types.second.id]) }

      it "changes to contact types in params" do
        expect(case_contact.contact_type_ids).to contain_exactly(contact_types.second.id)
        request

        case_contact.reload
        expect(case_contact.contact_type_ids).to contain_exactly(contact_types.first.id)
      end
    end

    context "when contact topic answers in params" do
      let(:contact_topics) { create_list(:contact_topic, 3, casa_org:) }
      let(:topic_one) { contact_topics.first }
      let(:contact_topic_answers_attributes) do
        {
          "0" => {contact_topic_id: topic_one.id, value: "Topic 1 Answer"},
          "1" => {contact_topic_id: contact_topics.second.id, value: "Topic 2 Answer"},
          "2" => {contact_topic_id: contact_topics.third.id, value: "Topic 3 Answer"}
        }
      end

      let(:attributes) { valid_attributes.merge({contact_topic_answers_attributes:}) }

      it "creates contact topic answers" do
        expect(attributes[:contact_topic_answers_attributes]).to eq contact_topic_answers_attributes
        request

        case_contact.reload
        expect(case_contact.contact_topic_answers.size).to eq 3
        expect(case_contact.contact_topic_answers.pluck(:value))
          .to contain_exactly("Topic 1 Answer", "Topic 2 Answer", "Topic 3 Answer")
        expect(case_contact.contact_topics.flat_map(&:id)).to match_array(contact_topics.collect(&:id))
      end

      context "when answer exists for the same contact topic" do
        let!(:contact_topic_one_answer) do
          create(:contact_topic_answer, value: "Original Discussion Topic Answer.", contact_topic: topic_one, case_contact:)
        end

        it "overwrites existing answer with id in answer attributes" do
          contact_topic_answers_attributes["0"][:id] = contact_topic_one_answer.id
          expect(case_contact.contact_topic_answers.size).to eq 1
          request

          case_contact.reload
          topic_one_contact_answers = case_contact.contact_topic_answers.where(contact_topic: topic_one)
          expect(topic_one_contact_answers.size).to eq 1
          expect(case_contact.contact_topic_answers.size).to eq 3
          expect(topic_one_contact_answers.first.value).to eq "Topic 1 Answer"
        end
      end

      context "when answer attribute has no contact_topic_id" do
        let(:contact_topic_answers_attributes) { {"0" => {value: "Topic 1 Answer"}} }

        it "saves the answer in contact.notes" do
          request

          expect(response).to redirect_to(case_contacts_path(success: true))
          expect(case_contact.reload.contact_topic_answers).to be_empty
          expect(case_contact.notes).to eq "Topic 1 Answer"
        end
      end
    end

    context "when notes attribute in params" do
      let(:notes) { "This is a note." }
      let(:attributes) { valid_attributes.merge({notes:}) }

      it "updates the requested case_contact" do
        request

        case_contact.reload
        expect(case_contact.notes).to eq "This is a note."
      end

      context "when answer with no contact topic id in attributes" do
        let(:contact_topic_answers_attributes) { {"0" => {value: "Topic 1 Answer"}} }
        let(:attributes) { valid_attributes.merge({notes:, contact_topic_answers_attributes:}) }

        it "combines notes and answer in contact.notes" do
          request

          expect(case_contact.reload.contact_topic_answers).to be_empty
          expect(case_contact.notes).to eq "This is a note.Topic 1 Answer"
        end
      end
    end

    it "does not send reimbursement email for non-reimbursement case contacts" do
      expect(attributes[:want_driving_reimbursement]).to be_nil

      expect { request }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end

    context "when no volunteer address in params" do
      before { volunteer.create_address!(content: "123 Before St") }

      it "does not update the volunteer's address" do
        expect(attributes[:volunteer_address]).to be_nil
        request

        expect(case_contact.reload.volunteer_address).to be_nil
        expect(volunteer.reload.address.content).to eq "123 Before St"
      end
    end

    context "when blank volunteer address in params" do
      let(:attributes) { valid_attributes.merge({volunteer_address: ""}) }

      before { volunteer.create_address!(content: "123 Before St") }

      it "does not update the volunteer's address" do
        expect(attributes[:volunteer_address]).to eq ""
        request

        expect(case_contact.reload.volunteer_address).to be_empty
        expect(volunteer.reload.address.content).to eq "123 Before St"
      end
    end

    context "when reimbursement info is in params" do
      let(:attributes) do
        valid_attributes.merge({
          want_driving_reimbursement: true,
          miles_driven: 60,
          volunteer_address: "123 Params St"
        })
      end

      it "updates the case contact with the info" do
        request

        case_contact.reload
        expect(case_contact.want_driving_reimbursement).to be true
        expect(case_contact.miles_driven).to eq 60
        expect(case_contact.volunteer_address).to eq "123 Params St"
      end

      it "sends reimbursement email" do
        expect {
          request
        }.to change { have_enqueued_job(ActionMailer::MailDeliveryJob).with("SupervisorMailer", "reimbursement_request_email", volunteer, supervisor) }
      end

      it "updates the volunteer's address with the new address" do
        expect(user).to eq volunteer
        expect(attributes[:volunteer_address]).to eq "123 Params St"
        request

        expect(case_contact.reload.volunteer_address).to eq "123 Params St"
        expect(volunteer.reload.address.content).to eq "123 Params St"
      end

      context "when admin edits volunteer contact" do
        let(:user) { casa_admin }

        it "changes the volunteer address, not the admin's" do
          casa_admin.create_address!(content: "321 Admin Ave")
          expect(attributes[:volunteer_address]).to eq "123 Params St"
          request

          expect(case_contact.reload.volunteer_address).to eq "123 Params St"
          expect(volunteer.reload.address.content).to eq "123 Params St"
          expect(casa_admin.reload.address&.content).to eq "321 Admin Ave"
        end
      end

      context "when supervisor edits volunteer contact" do
        let(:user) { supervisor }

        it "changes the volunteer address, not the supervisor's" do
          supervisor.create_address!(content: "321 Super Ave")
          expect(attributes[:volunteer_address]).to eq "123 Params St"
          request

          expect(case_contact.reload.volunteer_address).to eq "123 Params St"
          expect(volunteer.reload.address.content).to eq "123 Params St"
          expect(supervisor.reload.address&.content).to eq "321 Super Ave"
        end
      end
    end

    context "when additional expenses in params" do
      let(:additional_expenses_attributes) do
        {
          "0" => {other_expense_amount: 50, other_expenses_describe: "meal"},
          "1" => {other_expense_amount: 100, other_expenses_describe: "hotel"}
        }
      end
      let(:attributes) { valid_attributes.merge({additional_expenses_attributes:}) }

      it "creates additional expenses for the case contact" do
        request

        case_contact.reload
        expect(case_contact.additional_expenses.first.other_expense_amount).to eq 50
        expect(case_contact.additional_expenses.first.other_expenses_describe).to eq "meal"
        expect(case_contact.additional_expenses.last.other_expense_amount).to eq 100
        expect(case_contact.additional_expenses.last.other_expenses_describe).to eq "hotel"
      end

      it "succeeds when wants_driving_reimbursement is not true" do
        case_contact.update!(want_driving_reimbursement: false)
        attributes[:want_driving_reimbursement] = "0"
        request

        expect(case_contact.reload.additional_expenses.size).to eq 2
      end
    end

    context "when json request (autosave)" do
      subject(:request) do
        patch "/case_contacts/#{case_contact.id}/form/details", params:, as: :json

        response
      end

      it { is_expected.to have_http_status(:success) }

      it "updates with the attributes" do
        request

        case_contact.reload
        expect(case_contact.occurred_at).to eq(attributes[:occurred_at])
        expect(case_contact.contact_made).to be true
      end

      it "does not change status" do
        expect(case_contact.status).to eq "started"
        request

        expect(case_contact.reload.status).to eq "started"
      end

      context "when contact is in details status" do
        let(:case_contact) { create(:case_contact, :details_status, casa_case:, creator: volunteer) }

        it "does not change status" do
          expect(case_contact.status).to eq "details"
          request

          expect(case_contact.reload.status).to eq "details"
        end
      end

      context "when contact is in active status" do
        let(:case_contact) { create(:case_contact, casa_case:, creator: volunteer) }

        it "does not change the status" do
          expect(case_contact.status).to eq "active"
          request

          expect(case_contact.reload.status).to eq "active"
        end
      end

      context "when attribute is invalid" do
        let(:attributes) { invalid_attributes }

        it "does not update the requested case_contact" do
          expect { request }.not_to change(case_contact.reload, :attributes)
        end

        it "responds :unprocessable_entity and returns the errors" do
          request

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when metadata create_another attribute is truthy" do
      let(:attributes) { valid_attributes.merge({metadata: {create_another: "1"}}) }

      it "redirects to contact form with the same draft_case_id, ignore_referer" do
        expect(attributes[:draft_case_ids]).to be_present

        request
        expect(response).to have_http_status :redirect
        expect(response).to redirect_to(
          new_case_contact_path(draft_case_ids: attributes[:draft_case_ids], ignore_referer: true)
        )
      end
    end

    context "with multiple cases selected" do
      let!(:second_casa_case) { create(:casa_case, casa_org:, volunteers: [volunteer]) }
      let!(:third_casa_case) { create(:casa_case, casa_org:, volunteers: [volunteer]) }
      let(:draft_case_ids) { [casa_case.id, second_casa_case.id, third_casa_case.id] }

      it "copies the contact attributes for each contact" do
        expect { request }.to change(CaseContact.active, :count).by(3)

        original_case_contact = case_contact.reload
        second_case_contact = CaseContact.active.where(casa_case_id: second_casa_case.id).first
        third_case_contact = CaseContact.active.where(casa_case_id: third_casa_case.id).first

        unique_columns = ["id", "casa_case_id", "created_at", "updated_at", "draft_case_ids", "metadata"]
        copied_attrs = original_case_contact.attributes.except(*unique_columns)
        expect([second_case_contact, third_case_contact]).to all have_attributes copied_attrs
      end

      it "sets casa_case and draft_case_ids per contact" do
        expect { request }.to change(CaseContact.active, :count).by(3)

        second_case_contact = CaseContact.active.where(casa_case_id: second_casa_case.id).first
        third_case_contact = CaseContact.active.where(casa_case_id: third_casa_case.id).first

        expect(case_contact.reload.casa_case_id).to eq draft_case_ids.first
        expect(case_contact.draft_case_ids).to contain_exactly draft_case_ids.first
        expect(second_case_contact.casa_case_id).to eq draft_case_ids.second
        expect(second_case_contact.draft_case_ids).to contain_exactly draft_case_ids.second
        expect(third_case_contact.casa_case_id).to eq draft_case_ids.third
        expect(third_case_contact.draft_case_ids).to contain_exactly draft_case_ids.third
      end

      it "sets contact_type_ids for all contacts" do
        expect { request }.to change(CaseContact.active, :count).by(3)

        contacts = CaseContact.active.last(3)
        expect(contacts.collect(&:contact_type_ids)).to all match_array(contact_type_ids)
      end

      it "copies contact_topic answers for the cases" do
        case_contact.contact_topic_answers.create!(contact_topic: contact_topics.first, value: "test answer")
        expect { request }.to change(CaseContact.active, :count).by(3)

        contacts = CaseContact.active.last(3)
        contacts.each do |contact|
          expect(contact.contact_topic_answers.first.contact_topic_id).to eq contact_topics.first.id
          expect(contact.contact_topic_answers.first.value).to eq "test answer"
        end
      end

      it "redirects to referrer (fallback) page" do
        request
        expect(response).to have_http_status :redirect
        expect(response).to redirect_to case_contacts_path(success: true)
      end

      context "when create_another option is truthy" do
        before { params[:case_contact][:metadata] = {create_another: "1"} }

        it "redirects to new contact with the same draft_case_ids, :ignore_referer" do
          request
          expect(response).to have_http_status :redirect
          expect(response).to redirect_to new_case_contact_path(draft_case_ids:, ignore_referer: true)
        end
      end
    end
  end

  describe "invalid routes that used to exist" do
    # NOTE: these were the previously valid routes:
    # case_contact_form_index GET    /case_contacts/:case_contact_id/form(.:format)          case_contacts/form#index
    #                         POST   /case_contacts/:case_contact_id/form(.:format)          case_contacts/form#create
    # case_contact_form       DELETE /case_contacts/:case_contact_id/form/:id(.:format)      case_contacts/form#destroy

    let(:case_contact) { create(:case_contact, casa_case:, creator:) }
    let(:route) { "/case_contacts/#{case_contact.id}/form" }

    describe "GET /index" do
      subject(:request) { get route }

      it "raises a routing error" do
        expect { request }.to raise_error(ActionController::RoutingError)
      end
    end

    describe "POST /create" do
      # contact id needed for route (why this did not make sense)
      let(:attributes) { attributes_for(:case_contact, :started_status, status: nil, casa_case:, creator: nil) }

      subject(:request) { post route, params: {case_contact: attributes} }

      it "raises a routing error" do
        expect { request }.to raise_error(ActionController::RoutingError)
      end
    end

    describe "GET /edit" do
      subject(:request) { get "#{route}/edit" }

      it "raises a wicked wizard invalid step error" do
        expect { request }.to raise_error(Wicked::Wizard::InvalidStepError)
      end
    end

    describe "DELETE /destroy" do
      let(:case_contact) { create(:case_contact, casa_case:, creator:) }
      let(:route) { "/case_contacts/#{case_contact.id}/form/:details" }

      subject(:request) { delete route }

      it "raises a routing error" do
        expect { request }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
