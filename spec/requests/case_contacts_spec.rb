require "rails_helper"

RSpec.describe "/case_contacts", type: :request do
  let(:organization) { build(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:volunteer) { create(:volunteer, casa_org: organization) }

  before { sign_in admin }

  describe "GET /index" do
    subject(:request) do
      get case_contacts_path(filterrific: filterrific)

      response
    end

    let!(:casa_case) { create(:casa_case, casa_org: organization) }
    let!(:past_contact) { create(:case_contact, casa_case: casa_case, occurred_at: 3.weeks.ago) }
    let!(:recent_contact) { create(:case_contact, casa_case: casa_case, occurred_at: 3.days.ago) }
    let(:filterrific) { {} }

    it { is_expected.to have_http_status(:success) }

    it "returns all case contacts" do
      page = request.parsed_body.to_html
      expect(page).to include(past_contact.creator.display_name, recent_contact.creator.display_name)
    end

    context "with filters applied" do
      let(:filterrific) { {occurred_starting_at: 1.week.ago} }

      it "returns all case contacts" do
        page = request.parsed_body.to_html
        expect(page).to include(recent_contact.creator.display_name)
        expect(page).not_to include(past_contact.creator.display_name)
      end
    end

    context "when logged in as a volunteer" do
      let(:assigned_case) { create(:casa_case, :with_one_case_assignment, casa_org: organization) }
      let(:unassigned_case) { casa_case }
      let(:volunteer) { assigned_case.assigned_volunteers.first }
      let!(:assigned_case_contact) { create(:case_contact, casa_case: assigned_case, creator: volunteer) }
      let!(:unassigned_case_contact) { create(:case_contact, casa_case: unassigned_case, creator: volunteer, duration_minutes: 180) }

      before { sign_in volunteer }

      it "returns only currently assigned cases" do
        page = request.parsed_body.to_html
        expect(page).to include("60 minutes")
        expect(page).not_to include("3 hours")
      end
    end
  end

  describe "GET /new" do
    subject(:request) do
      get new_case_contact_path

      response
    end

    it { is_expected.to have_http_status(:redirect) }

    it "creates a 'started' status case contact and redirects to the form" do
      expect { request }.to change(CaseContact, :count).by(1)
      new_case_contact = CaseContact.last
      expect(new_case_contact.status).to eq "started"
      expect(response).to redirect_to(case_contact_form_path(:details, case_contact_id: new_case_contact.id))
    end

    context "when current org has contact topics" do
      let(:contact_topics) do
        [build(:contact_topic, active: true, soft_delete: false)]
      end
      let(:organization) { create(:casa_org, contact_topics:) }

      it "does not create contact topic answers" do
        expect { request }
          .to change(CaseContact.started, :count).by(1)
          .and not_change(ContactTopicAnswer, :count)

        expect(CaseContact.started.last.contact_topic_answers).to be_empty
      end
    end
  end

  describe "GET /edit" do
    subject(:request) do
      get edit_case_contact_url(case_contact)

      response
    end

    let(:case_contact) { create(:case_contact, casa_case: create(:casa_case, :with_case_assignments), notes: "Notes") }

    it { is_expected.to have_http_status(:redirect) }

    it "redirects to case contact form" do
      request
      expect(response).to redirect_to(case_contact_form_path(:details, case_contact_id: case_contact.id))
    end
  end

  describe "GET /drafts" do
    subject(:request) do
      get case_contacts_drafts_path

      response
    end

    it { is_expected.to have_http_status(:success) }

    context "when user is volunteer" do
      before { sign_in volunteer }

      it { is_expected.to have_http_status(:redirect) }
    end
  end

  describe "DELETE /destroy" do
    subject(:request) do
      delete case_contact_path(case_contact), headers: {HTTP_REFERER: case_contacts_path}

      response
    end

    let(:case_contact) { create(:case_contact) }

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
    subject(:request) do
      post restore_case_contact_path(case_contact), headers: {HTTP_REFERER: case_contacts_path}

      response
    end

    let(:case_contact) { create(:case_contact) }

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

  xdescribe "GET /leave" do
    subject(:request) do
      get leave_case_contact_path

      response
    end

    it { is_expected.to redirect_to(case_contacts_path) }

    it "redirects back to referer or fallback location" do
      request
      expect(response).to redirect_to(case_contacts_path)
    end
  end
end
