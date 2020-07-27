require "rails_helper"

RSpec.describe "/case_contacts", type: :request do
  let(:volunteer) { create(:user, :volunteer) }
  let(:other_volunteer) { create(:user, :volunteer) }

  let(:valid_attributes) do
    attributes_for(:case_contact).merge(
      creator: volunteer,
      casa_case_id: [
        create(:casa_case, volunteers: [volunteer]).id,
        create(:casa_case, volunteers: [volunteer]).id,
      ]
    )
  end

  let(:invalid_attributes) do
    {
      creator: nil,
      casa_case_id: [create(:casa_case, volunteers: [volunteer]).id],
      contact_types: ["invalid type"],
      occurred_at: Time.zone.now
    }
  end

  before { sign_in volunteer }

  describe "GET /index" do
    it "renders a successful response" do
      create(:case_contact)
      get case_contacts_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      case_contact = create(:case_contact, creator: volunteer)
      get case_contact_url(case_contact)
      expect(response).to be_successful
    end
  end

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
            case_contact: valid_attributes.merge(casa_case_id: []),
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
        case_contact = create(:case_contact, creator: volunteer)

        patch case_contact_url(case_contact), params: {
          case_contact: {
            contact_types: ["attorney"],
          }
        }
        expect(response).to redirect_to(casa_case_path(case_contact.casa_case_id))

        case_contact.reload
        expect(case_contact.contact_types).to eq(["attorney"])
      end
    end

    context "as another volunteer" do
      before { sign_in other_volunteer }

      it "does not allow update of case contacts created by other volunteers" do
        case_contact = create(:case_contact, creator: volunteer, contact_types: ["therapist"])

        patch case_contact_url(case_contact), params: {
          case_contact: {
            contact_types: ["attorney"],
          }
        }
        expect(response).to redirect_to(root_path)

        case_contact.reload
        expect(case_contact.contact_types).to eq(["therapist"])
      end
    end

    context "with invalid parameters" do
      it "renders a successful response (i.e. to display the edit template)" do
        case_contact = create(:case_contact, creator: volunteer)
        patch case_contact_url(case_contact), params: {case_contact: invalid_attributes}
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested case_contact" do
      case_contact = create(:case_contact, creator: volunteer)
      expect {
        delete case_contact_url(case_contact)
      }.to change(CaseContact, :count).by(-1)
    end

    it "redirects to the case_contacts list" do
      case_contact = create(:case_contact, creator: volunteer)
      delete case_contact_url(case_contact)
      expect(response).to redirect_to(case_contacts_url)
    end
  end
end
