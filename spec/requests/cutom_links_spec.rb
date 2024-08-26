require 'rails_helper'

RSpec.describe CustomLinksController, type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:casa_admin, casa_org: user.casa_org) }
  let(:custom_link) { create(:custom_link, casa_org_id: user.casa_org_id) }
  let(:valid_attributes) { { text: 'Link Text', url: 'http://example.com', active: true, casa_org_id: user.casa_org_id } }
  let(:invalid_attributes) { { text: '', url: 'invalid', active: nil } }

  before do
    sign_in user
    allow_any_instance_of(CustomLinkPolicy).to receive(:new?).and_return(true)
    allow_any_instance_of(CustomLinkPolicy).to receive(:edit?).and_return(true)
    allow_any_instance_of(CustomLinkPolicy).to receive(:create?).and_return(true)
    allow_any_instance_of(CustomLinkPolicy).to receive(:update?).and_return(true)
    allow_any_instance_of(CustomLinkPolicy).to receive(:destroy?).and_return(true)
  end

  describe 'GET #new' do
    it 'authorizes the action' do
      expect_any_instance_of(CustomLinkPolicy).to receive(:new?).and_return(true)
      get new_custom_link_path
    end

    it 'assigns a new CustomLink with the current user\'s casa_org_id to @custom_link' do
      get new_custom_link_path
      expect(assigns(:custom_link)).to be_a_new(CustomLink)
      expect(assigns(:custom_link).casa_org_id).to eq(user.casa_org_id)
    end

    it 'renders the new template' do
      get new_custom_link_path
      expect(response).to render_template(:new)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested custom_link as @custom_link' do
      get edit_custom_link_path(custom_link)
      expect(assigns(:custom_link)).to eq(custom_link)
    end

    it 'authorizes the action' do
      expect_any_instance_of(CustomLinkPolicy).to receive(:edit?).and_return(true)
      get edit_custom_link_path(custom_link)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new CustomLink' do
        expect do
          post custom_links_path, params: { custom_link: valid_attributes }
        end.to change(CustomLink, :count).by(1)
      end

      it 'redirects to the edit_casa_org_path' do
        post custom_links_path, params: { custom_link: valid_attributes }
        expect(response).to redirect_to(edit_casa_org_path(user.casa_org))
      end

      it 'sets a success notice' do
        post custom_links_path, params: { custom_link: valid_attributes }
        expect(flash[:notice]).to eq('Custom link was successfully created.')
      end

      it 'authorizes the action' do
        expect_any_instance_of(CustomLinkPolicy).to receive(:create?).and_return(true)
        post custom_links_path, params: { custom_link: valid_attributes }
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new CustomLink' do
        expect do
          post custom_links_path, params: { custom_link: invalid_attributes }
        end.to change(CustomLink, :count).by(0)
      end

      it 'renders the new template' do
        post custom_links_path, params: { custom_link: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH/PUT #update' do
    context 'with valid parameters' do
      let(:new_attributes) { { text: 'Updated Text', url: 'http://updated.com' } }

      it 'updates the requested custom_link' do
        patch custom_link_path(custom_link), params: { custom_link: new_attributes }
        custom_link.reload
        expect(custom_link.text).to eq('Updated Text')
      end

      it 'redirects to the edit_casa_org_path' do
        patch custom_link_path(custom_link), params: { custom_link: new_attributes }
        expect(response).to redirect_to(edit_casa_org_path(user.casa_org))
      end

      it 'sets a success notice' do
        patch custom_link_path(custom_link), params: { custom_link: new_attributes }
        expect(flash[:notice]).to eq('Custom link was successfully updated.')
      end

      it 'authorizes the action' do
        expect_any_instance_of(CustomLinkPolicy).to receive(:update?).and_return(true)
        patch custom_link_path(custom_link), params: { custom_link: new_attributes }
      end
    end

    context 'with invalid parameters' do
      it 'does not update the requested custom_link' do
        patch custom_link_path(custom_link), params: { custom_link: invalid_attributes }
        custom_link.reload
        expect(custom_link.text).not_to be_empty
      end

      it 'renders the edit template' do
        patch custom_link_path(custom_link), params: { custom_link: invalid_attributes }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested custom_link' do
      custom_link
      expect do
        delete custom_link_path(custom_link)
      end.to change(CustomLink, :count).by(-1)
    end

    it 'redirects to the edit_casa_org_path' do
      delete custom_link_path(custom_link)
      expect(response).to redirect_to(edit_casa_org_path(user.casa_org))
    end

    it 'sets a success notice' do
      delete custom_link_path(custom_link)
      expect(flash[:notice]).to eq('Custom link was successfully removed.')
    end

    it 'authorizes the action' do
      expect_any_instance_of(CustomLinkPolicy).to receive(:destroy?).and_return(true)
      delete custom_link_path(custom_link)
    end
  end
end
