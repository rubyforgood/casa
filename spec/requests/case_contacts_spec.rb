require "rails_helper"

RSpec.describe "/case_contacts", type: :request do
  let(:organization) { build(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:volunteer) { create(:volunteer, casa_org: organization) }

  before { sign_in admin }

  describe "GET /index" do
    let!(:casa_case) { create(:casa_case, casa_org: organization) }
    let!(:past_contact) { create(:case_contact, casa_case: casa_case, occurred_at: 3.weeks.ago) }
    let!(:recent_contact) { create(:case_contact, casa_case: casa_case, occurred_at: 3.days.ago) }
    let(:filterrific) { {} }

    subject(:request) do
      get case_contacts_path(filterrific: filterrific)

      response
    end

    it { is_expected.to have_http_status(:success) }

    it "returns all case contacts" do
      page = request.parsed_body
      expect(page).to include(past_contact.creator.display_name, recent_contact.creator.display_name)
    end

    context "with filters applied" do
      let(:filterrific) { {occurred_starting_at: 1.week.ago} }

      it "returns all case contacts" do
        page = request.parsed_body
        expect(page).to include(recent_contact.creator.display_name)
        expect(page).not_to include(past_contact.creator.display_name)
      end
    end
  end

  describe "GET /new" do
    let!(:casa_case) { create(:casa_case, casa_org: organization) }
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
      get new_case_contact_path

      response
    end

    it { is_expected.to have_http_status(:success) }

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
      let!(:other_casa_case) { create(:casa_case, :with_casa_case_contact_types, casa_org: organization) }

      subject(:request) do
        get new_case_contact_path(case_contact: {casa_case_id: other_casa_case.id})

        response
      end

      it "shows only contact types assigned to selected casa case" do
        page = request.parsed_body
        expect(page).to include(*other_casa_case.contact_types.pluck(:name))
        expect(page).not_to include(*contact_types_a.pluck(:name))
        expect(page).not_to include(*contact_types_b.pluck(:name))
      end
    end
  end

  describe "POST /create" do
    let!(:casa_case) { create(:casa_case, casa_org: organization) }

    subject(:request) do
      post case_contacts_url, params: params

      response
    end

    context "with valid parameters" do
      let(:selected_casa_case_ids) { [casa_case.id] }
      let(:valid_attributes) do
        attributes_for(:case_contact, :wants_reimbursement, casa_case: casa_case).merge(
          casa_case_id: selected_casa_case_ids
        )
      end
      let(:params) { {case_contact: valid_attributes} }

      it "creates a new CaseContact with correct values", :aggregate_failures do
        expect { request }.to change(CaseContact, :count).from(0).to(1)

        case_contact = CaseContact.first
        expect(case_contact.creator).to eq(admin)
        expect(case_contact.casa_case).to eq(casa_case)
        expect(case_contact.occurred_at).to eq(valid_attributes[:occurred_at].floor)
        expect(case_contact.duration_minutes).to eq(60)
        expect(case_contact.contact_made).to eq(false)
        expect(case_contact.miles_driven).to eq(456)
        expect(case_contact.medium_type).to eq(CaseContact::CONTACT_MEDIUMS.first)
        expect(case_contact.want_driving_reimbursement).to eq(true)
      end

      it "redirects to casa_case#show" do
        expect(request).to redirect_to(casa_case_url(casa_case, success: true))
      end

      context "when multiple casa cases were selected" do
        let!(:other_casa_case) { create(:casa_case, casa_org: organization) }
        let(:selected_casa_case_ids) { [casa_case.id, other_casa_case.id] }

        it "creates two new CaseContacts" do
          expect { request }.to change(CaseContact, :count).by(2)
        end

        it "redirects to the case contact page" do
          expect(request).to redirect_to(case_contacts_path(success: true))
        end
      end

      context "reimbursement mail to supervisor" do
        let(:supervisor) { create(:supervisor, receive_reimbursement_email: true, casa_org: organization) }
        let(:volunteer) { create(:volunteer, supervisor: supervisor, casa_org: organization) }
        let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }

        before do
          sign_in volunteer
        end

        it "sends reimbursement request email when conditions are met" do
          mailer_double = double("SupervisorMailer")
          allow(SupervisorMailer).to receive(:reimbursement_request_email).and_return(mailer_double)

          expect(mailer_double).to receive(:deliver_later)
          request
        end

        it "does not send reimbursement request email when conditions are not met" do
          supervisor.update(active: false)
          mailer_double = double("SupervisorMailer")
          allow(SupervisorMailer).to receive(:reimbursement_request_email).and_return(mailer_double)

          expect(mailer_double).not_to receive(:deliver_later)
          request
        end
      end

      context "with additional expense" do
        let(:params) do
          {
            case_contact: valid_attributes.merge(
              additional_expenses_attributes: {"0" => attributes_for(:additional_expense)}
            )
          }
        end

        before do
          FeatureFlagService.enable!(FeatureFlagService::SHOW_ADDITIONAL_EXPENSES_FLAG)
          organization.additional_expenses_enabled = true
        end

        it "creates an additional expense with correct values", :aggregate_failures do
          expect { request }.to change(AdditionalExpense, :count).from(0).to(1)

          additional_expense = CaseContact.first.additional_expenses.first
          expect(additional_expense.other_expense_amount).to eq(20)
          expect(additional_expense.other_expenses_describe).to eq("description of expense")
        end
      end

      context "with contact types" do
        let!(:contact_type_group) { create(:contact_type_group, casa_org: organization) }
        let!(:contact_type) { create(:contact_type, contact_type_group: contact_type_group) }
        let(:params) do
          {
            case_contact: valid_attributes.merge(
              case_contact_contact_type_attributes: {"0" => {contact_type_id: contact_type.id}}
            )
          }
        end

        it "creates the correct contact_type association", :aggregate_failures do
          request
          expect(CaseContact.first.contact_types.first).to eq(contact_type)
        end
      end

      context "with volunteer address" do
        let(:casa_case) { volunteer.casa_cases.first }
        let(:valid_attributes) {
          build(:case_contact, casa_case_id: casa_case.id).attributes.merge(
            casa_case_attributes: {
              id: casa_case.id, volunteers_attributes: {
                "0" => {
                  id: volunteer.id,
                  address_attributes: {
                    id: 0, content: "Volunteer address"
                  }
                }
              }
            }
          )
        }

        context "when volunteer already has a address created" do
          let(:volunteer) { create(:volunteer, :with_casa_cases, casa_org: organization, address: build(:address)) }

          it "updates volunteer address" do
            expect { request }.to change(CaseContact, :count).from(0).to(1)
            expect(casa_case.volunteers.first.address.content).to eq("Volunteer address")
          end
        end

        context "when volunteer doesnt have a address created" do
          let(:volunteer) { create(:volunteer, :with_casa_cases, casa_org: organization, address: nil) }
          it "create new volunteer address" do
            expect { request }.to change(CaseContact, :count).from(0).to(1)
            expect(casa_case.volunteers.first.address.content).to eq("Volunteer address")
          end
        end
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { {creator: nil, casa_case_id: [casa_case.id], occurred_at: Time.zone.now} }
      let(:params) { {case_contact: invalid_attributes} }

      it { is_expected.to have_http_status(:success) }

      it "does not create a new CaseContact" do
        expect { request }.not_to change(CaseContact, :count)
      end

      describe ": no casa cases" do
        let(:invalid_attributes) { {creator: nil, casa_case_id: [], occurred_at: Time.zone.now} }

        it { is_expected.to have_http_status(:success) }

        it "does not create a new CaseContact" do
          expect { request }.not_to change(CaseContact, :count)
        end

        it "shows alert message" do
          request
          expect(flash[:alert]).to eq("At least one case must be selected")
        end
      end
    end
  end

  describe "GET /edit" do
    let(:case_contact) { create(:case_contact, casa_case: create(:casa_case, :with_case_assignments), notes: "Notes") }

    subject(:request) do
      get edit_case_contact_url(case_contact)

      response
    end

    it { is_expected.to have_http_status(:success) }

    it "shows edit page with the correct case_contact" do
      page = request.parsed_body
      expect(page).to include(case_contact.notes)
    end

    describe "unread notification" do
      let(:followup) { create(:followup, case_contact: case_contact, creator: admin) }

      subject(:request) do
        get edit_case_contact_url(case_contact, notification_id: admin.notifications.first.id)

        response
      end

      before { FollowupResolvedNotification.with(followup: followup, created_by: admin).deliver(followup.creator) }

      it "is marked as read" do
        request
        expect(admin.notifications.unread).to eq([])
      end
    end
  end

  describe "PATCH /update" do
    let!(:casa_case) { create(:casa_case, casa_org: organization) }
    let(:case_contact) { create(:case_contact, creator: admin, casa_case: casa_case) }

    subject(:request) do
      patch case_contact_url(case_contact), params: params

      response
    end

    context "with valid parameters" do
      let(:selected_casa_case_ids) { [casa_case.id] }
      let(:valid_attributes) do
        {
          occurred_at: 3.days.ago,
          duration_minutes: 50,
          contact_made: true,
          miles_driven: 600,
          medium_type: CaseContact::CONTACT_MEDIUMS.second,
          want_driving_reimbursement: false
        }
      end
      let(:params) { {case_contact: valid_attributes} }

      it { is_expected.to redirect_to(casa_case_path(casa_case.case_number.parameterize)) }

      it "updates the requested case_contact", :aggregate_failures do
        request
        case_contact.reload
        expect(case_contact.occurred_at).to eq(valid_attributes[:occurred_at].floor)
        expect(case_contact.duration_minutes).to eq(50)
        expect(case_contact.contact_made).to eq(true)
        expect(case_contact.miles_driven).to eq(600)
        expect(case_contact.medium_type).to eq(CaseContact::CONTACT_MEDIUMS.second)
        expect(case_contact.want_driving_reimbursement).to eq(false)
      end
    end

    context "with invalid parameters" do
      let!(:other_casa_case) { create(:casa_case, casa_org: organization) }
      let(:invalid_attributes) { {creator: volunteer, casa_case_id: [other_casa_case.id]} }
      let(:params) { {case_contact: invalid_attributes} }

      it { is_expected.to have_http_status(:success) }

      it "does not update the case_contact" do
        request
        expect(case_contact.creator).not_to eq(volunteer)
        expect(case_contact.casa_case_id).not_to eq(other_casa_case.id)
      end
    end
  end

  describe "DELETE /destroy" do
    let(:case_contact) { create(:case_contact) }

    subject(:request) do
      delete case_contact_path(case_contact), headers: {HTTP_REFERER: case_contacts_path}

      response
    end

    it { is_expected.to redirect_to(case_contacts_path) }

    it "shows correct flash message" do
      request
      expect(flash[:notice]).to eq("Contact is successfully deleted.")
    end

    it "soft deletes the case_contact" do
      expect { request }.to change { case_contact.reload.deleted? }.from(false).to(true)
    end
  end

  describe "GET /restore" do
    let(:case_contact) { create(:case_contact) }

    subject(:request) do
      post restore_case_contact_path(case_contact), headers: {HTTP_REFERER: case_contacts_path}

      response
    end

    before { case_contact.destroy }

    it { is_expected.to redirect_to(case_contacts_path) }

    it "shows correct flash message" do
      request
      expect(flash[:notice]).to eq("Contact is successfully restored.")
    end

    it "soft deletes the case_contact" do
      expect { request }.to change { case_contact.reload.deleted? }.from(true).to(false)
    end
  end
end
