require 'rails_helper'

RSpec.describe '/casa_cases', type: :request do
  # CasaCase. As you add validations to CasaCase, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { case_number: '1234', teen_program_eligible: true } }

  let(:invalid_attributes) { { case_number: nil } }

  before { sign_in create(:user, :casa_admin) }

  describe 'GET /index' do
    it 'renders a successful response' do
      CasaCase.create! valid_attributes
      get casa_cases_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      casa_case = CasaCase.create! valid_attributes
      get casa_case_url(casa_case)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      sign_in create(:user, :casa_admin)
      get new_casa_case_url
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'render a successful response' do
      casa_case = CasaCase.create! valid_attributes
      get edit_casa_case_url(casa_case)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new CasaCase' do
        expect { post casa_cases_url, params: { casa_case: valid_attributes } }.to change(
          CasaCase,
          :count
        ).by(1)
      end

      it 'redirects to the created casa_case' do
        post casa_cases_url, params: { casa_case: valid_attributes }
        expect(response).to redirect_to(casa_case_url(CasaCase.last))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new CasaCase' do
        expect { post casa_cases_url, params: { casa_case: invalid_attributes } }.to change(
          CasaCase,
          :count
        ).by(0)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        post casa_cases_url, params: { casa_case: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { case_number: '12345', teen_program_eligible: false } }

      it 'does not update case_number for volunteers' do
        sign_in create(:user, :volunteer)

        casa_case = CasaCase.create! valid_attributes
        patch casa_case_url(casa_case), params: { casa_case: new_attributes }
        casa_case.reload
        expect(casa_case.case_number).to eq '1234'
        expect(casa_case.teen_program_eligible).to eq false
      end

      it 'updates the requested casa_case' do
        casa_case = CasaCase.create! valid_attributes
        patch casa_case_url(casa_case), params: { casa_case: new_attributes }
        casa_case.reload
        expect(casa_case.case_number).to eq '12345'
        expect(casa_case.teen_program_eligible).to eq false
      end

      it 'redirects to the casa_case' do
        casa_case = CasaCase.create! valid_attributes
        patch casa_case_url(casa_case), params: { casa_case: new_attributes }
        casa_case.reload
        expect(response).to redirect_to(root_path)
      end
    end

    context 'with invalid parameters' do
      it "renders a successful response (i.e. to display the 'edit' template)" do
        casa_case = CasaCase.create! valid_attributes
        patch casa_case_url(casa_case), params: { casa_case: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested casa_case' do
      casa_case = CasaCase.create! valid_attributes
      expect { delete casa_case_url(casa_case) }.to change(CasaCase, :count).by(-1)
    end

    it 'redirects to the casa_cases list' do
      casa_case = CasaCase.create! valid_attributes
      delete casa_case_url(casa_case)
      expect(response).to redirect_to(casa_cases_url)
    end
  end
end
