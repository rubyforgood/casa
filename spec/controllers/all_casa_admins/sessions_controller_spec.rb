# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AllCasaAdmins::SessionsController, type: :controller do
  let(:all_casa_admin) { create(:all_casa_admin) }

  describe "Implements Devise's actions" do
    before { @request.env['devise.mapping'] = Devise.mappings[:all_casa_admin] }

    it 'GET new' do
      get :new
      expect(response).to be_successful
    end

    it 'POST create' do
      post :create, params: { email: all_casa_admin.email, password: all_casa_admin.password }
      expect(response).to be_successful
    end

    it 'GET destroy' do
      get :destroy
      expect(response).to have_http_status(:redirect)
    end
  end
end
