require "rails_helper"

# Every record-level action must be limited to the signed-in user's CASA org.
# A user in org A acting on org B's records must be refused and must not change anything.
RSpec.describe "Cross-organization authorization", type: :request do
  let(:other_org) { create(:casa_org) }
  let(:own_org) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: own_org) }
  let(:supervisor) { create(:supervisor, casa_org: own_org) }
  let(:volunteer) { create(:volunteer, casa_org: own_org) }

  let(:other_case) { create(:casa_case, casa_org: other_org) }
  let(:other_case_contact) { create(:case_contact, casa_case: other_case, creator: create(:volunteer, casa_org: other_org)) }

  def expect_refused
    if response.status == 404
      expect(response).to have_http_status(:not_found)
    else
      expect(response).to redirect_to(root_url)
      expect(flash[:alert]).to eq("Sorry, you are not authorized to perform this action.")
    end
  end

  describe "casa admins" do
    let!(:other_admin) { create(:casa_admin, casa_org: other_org, email: "other-admin@example.com") }

    before { sign_in admin }

    it "cannot change another org's admin's email" do
      patch casa_admin_path(other_admin), params: {casa_admin: {email: "attacker@example.com", display_name: "Changed"}}

      expect_refused
      other_admin.reload
      expect(other_admin.unconfirmed_email).to be_nil
      expect(other_admin.display_name).not_to eq("Changed")
    end

    it "cannot demote another org's admin" do
      patch change_to_supervisor_casa_admin_path(other_admin)

      expect_refused
      expect(User.find(other_admin.id)).to be_a(CasaAdmin)
    end

    it "cannot deactivate, activate or resend invitations for another org's admin" do
      patch deactivate_casa_admin_path(other_admin)
      expect_refused
      patch activate_casa_admin_path(other_admin)
      expect_refused
      patch resend_invitation_casa_admin_path(other_admin)
      expect_refused
      expect(other_admin.reload).to be_active
    end
  end

  describe "supervisors" do
    let!(:other_supervisor) { create(:supervisor, casa_org: other_org) }

    it "cannot be promoted to admin by another org's admin" do
      sign_in admin
      patch change_to_admin_supervisor_path(other_supervisor)

      expect_refused
      expect(User.find(other_supervisor.id)).to be_a(Supervisor)
    end
  end

  describe "court orders" do
    let!(:other_court_order) { create(:case_court_order, casa_case: other_case) }

    [:admin, :supervisor, :volunteer].each do |role|
      it "cannot be deleted by another org's #{role}" do
        sign_in public_send(role)
        delete case_court_order_path(other_court_order)

        expect(response).to have_http_status(:not_found)
        expect(CaseCourtOrder.exists?(other_court_order.id)).to be true
      end
    end

    it "can still be deleted by an admin of the same org" do
      own_order = create(:case_court_order, casa_case: create(:casa_case, casa_org: own_org))
      sign_in admin
      delete case_court_order_path(own_order)

      expect(CaseCourtOrder.exists?(own_order.id)).to be false
    end
  end

  describe "followups" do
    [:admin, :supervisor, :volunteer].each do |role|
      it "cannot be created on another org's case contact by a #{role}" do
        sign_in public_send(role)

        expect {
          post case_contact_followups_path(other_case_contact), params: {note: "cross-org"}
        }.not_to change(Followup, :count)
        expect_refused
      end

      it "cannot be resolved on another org's case contact by a #{role}" do
        followup = create(:followup, case_contact: other_case_contact)
        sign_in public_send(role)
        patch resolve_followup_path(followup)

        expect_refused
        expect(followup.reload).not_to be_resolved
      end
    end
  end

  describe "org configuration" do
    before { sign_in admin }

    %i[judge hearing_type learning_hour_type learning_hour_topic language].each do |name|
      it "cannot update another org's #{name.to_s.humanize(capitalize: false)}" do
        record = create(name, casa_org: other_org)
        original_name = record.name
        patch public_send(:"#{name}_path", record), params: {name => {name: "Changed by another org"}}

        expect_refused
        expect(record.reload.name).to eq(original_name)
      end
    end

    it "cannot update another org's contact type" do
      contact_type = create(:contact_type, contact_type_group: create(:contact_type_group, casa_org: other_org))
      patch contact_type_path(contact_type), params: {contact_type: {name: "Changed by another org", contact_type_group_id: contact_type.contact_type_group_id}}

      expect_refused
      expect(contact_type.reload.name).not_to eq("Changed by another org")
    end

    it "cannot open another org's judge edit page" do
      get edit_judge_path(create(:judge, casa_org: other_org))

      expect_refused
    end
  end
end
