require 'rails_helper'

RSpec.describe '/case_contacts', type: :request do
  let(:volunteer) { create(:user, :volunteer) }
  let(:other_volunteer) { create(:user, :volunteer) }
  let(:parent_casa_case) { create(:casa_case, volunteers: [volunteer]) }

  let(:valid_attributes) do
    attributes_for(:case_contact).merge(
      creator: volunteer,
      casa_case: create(:casa_case, volunteers: [volunteer]),
    )
  end

  let(:invalid_attributes) do
    {
      creator: nil,
      casa_case_id: parent_casa_case.id,
      contact_type: nil,
      occurred_at: Time.zone.now
    }
  end

  before do
    sign_in volunteer
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      CaseContact.create! valid_attributes
      get case_contacts_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      case_contact = CaseContact.create! valid_attributes
      get case_contact_url(case_contact)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with invalid parameters' do
      it 'does not create a new CaseContact' do
        expect {
          post case_contacts_url, params: { case_contact: invalid_attributes }
        }.to change(CaseContact, :count).by(0)
      end

      it 'renders a successful response (i.e. to display the new template)' do
        post case_contacts_url, params: { case_contact: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) {
        attributes_for(:case_contact).merge(
          creator: other_volunteer,
          casa_case: create(:casa_case, volunteers: [volunteer])
        )
      }

      it 'updates the requested case_contact' do
        case_contact = CaseContact.create! valid_attributes
        patch case_contact_url(case_contact), params: { case_contact: new_attributes }
        case_contact.reload
        expect(case_contact.casa_case).to eq volunteer.casa_cases.first
      end

      it 'redirects to the case_contact' do
        case_contact = CaseContact.create! valid_attributes
        patch case_contact_url(case_contact), params: { case_contact: new_attributes }
        case_contact.reload
        expect(response).to redirect_to(root_path)
      end
    end

    context 'with invalid parameters' do
      it 'renders a successful response (i.e. to display the edit template)' do
        case_contact = CaseContact.create! valid_attributes
        patch case_contact_url(case_contact), params: { case_contact: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested case_contact' do
      case_contact = CaseContact.create! valid_attributes
      expect {
        delete case_contact_url(case_contact)
      }.to change(CaseContact, :count).by(-1)
    end

    it 'redirects to the case_contacts list' do
      case_contact = CaseContact.create! valid_attributes
      delete case_contact_url(case_contact)
      expect(response).to redirect_to(case_contacts_url)
    end
  end
end
