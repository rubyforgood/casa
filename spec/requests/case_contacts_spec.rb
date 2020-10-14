require "rails_helper"

RSpec.describe "/case_contacts", type: :request do
  let(:organization) { create(:casa_org) }
  let(:volunteer) { create(:volunteer, casa_org: organization) }
  let(:other_volunteer) { create(:volunteer, casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }

  let(:valid_attributes) do
    attributes_for(:case_contact, casa_case: casa_case).merge(
      creator: volunteer,
      casa_case_id: [
        create(:casa_case, volunteers: [volunteer], casa_org: organization).id,
        create(:casa_case, volunteers: [volunteer], casa_org: organization).id
      ]
    )
  end

  let(:invalid_attributes) do
    {
      creator: nil,
      casa_case_id: [create(:casa_case, volunteers: [volunteer], casa_org: organization).id],
      occurred_at: Time.zone.now
    }
  end

  before { sign_in volunteer }

  describe "POST /create" do
    context "with valid parameters" do
      it "does create two new CaseContacts" do
        expect {
          post case_contacts_url, params: {case_contact: valid_attributes}
        }.to change(CaseContact, :count).by(2)
      end
    end

    context "with invalid parameters" do
      it "does not create a new CaseContact" do
        expect { post case_contacts_url, params: {case_contact: invalid_attributes} }.to change(
          CaseContact,
          :count
        ).by(0)
      end

      it "renders a successful response (i.e. to display the new template)" do
        post case_contacts_url, params: {case_contact: invalid_attributes}
        expect(response).to be_successful
      end
    end

    context "with no cases selected" do
      it "presents the user with a relevant error message" do
        expect {
          post case_contacts_url, params: {
            case_contact: valid_attributes.merge(casa_case_id: [])
          }
        }.to change(CaseContact, :count).by(0)

        expect(response).to be_successful
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      it "updates the requested case_contact and redirects to the root path" do
        case_contact = create(:case_contact, creator: volunteer, casa_case: casa_case)
        contact_type = create(:contact_type, name: "Attorney")

        patch case_contact_url(case_contact), params: {
          case_contact: {
            case_contact_contact_type_attributes: [{contact_type_id: contact_type.id}],
            duration_minutes: 60
          }
        }
        expect(response).to redirect_to(casa_case_path(case_contact.casa_case_id))

        expect(case_contact.reload.contact_types.first.name).to eq "Attorney"
      end
    end

    context "as another volunteer" do
      before { sign_in other_volunteer }

      it "does not allow update of case contacts created by other volunteers" do
        contact_type = create(:contact_type, name: "Attorney")
        contact_type2 = create(:contact_type, name: "Therapist")
        case_contact = create(:case_contact, creator: volunteer, casa_case: casa_case, contact_types: [contact_type])

        patch case_contact_url(case_contact), params: {
          case_contact: {
            contact_types: [contact_type2]
          }
        }
        expect(response).to redirect_to(root_path)

        case_contact.reload
        expect(case_contact.contact_types.first.name).to eq("Attorney")
      end
    end

    context "with invalid parameters" do
      it "renders a successful response (i.e. to display the edit template)" do
        case_contact = create(:case_contact, creator: volunteer, casa_case: casa_case)
        patch case_contact_url(case_contact), params: {case_contact: invalid_attributes}
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested case_contact" do
      case_contact = create(:case_contact, creator: volunteer, casa_case: casa_case)
      expect {
        delete case_contact_url(case_contact)
      }.to change(CaseContact, :count).by(-1)
    end

    it "redirects to the case_contacts list" do
      case_contact = create(:case_contact, creator: volunteer, casa_case: casa_case)
      delete case_contact_url(case_contact)
      expect(response).to redirect_to(case_contacts_url)
    end
  end
end
