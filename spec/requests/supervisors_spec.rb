# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/supervisors', type: :request do
  let(:admin) { create(:user, :casa_admin) }
  let(:supervisor) { create(:user, :supervisor) }

  describe 'GET /new' do
    it 'admin can view the new supervisor page' do
      sign_in admin

      get new_supervisor_url

      expect(response).to be_successful
    end

    it 'supervisors can not view the new supervisor page' do
      sign_in supervisor

      get new_supervisor_url

      expect(response).to_not be_successful
    end
  end

  describe 'GET /edit' do
    it 'admin can view the edit supervisor page' do
      sign_in admin

      get edit_supervisor_url(supervisor)

      expect(response).to be_successful
    end

    it 'supervisor can view the edit supervisor page' do
      sign_in supervisor

      get edit_supervisor_url(supervisor)

      expect(response).to be_successful
    end

    it 'other supervisor can view the edit supervisor page' do
      sign_in create(:user, :supervisor)

      get edit_supervisor_url(supervisor)

      expect(response).to be_successful
    end
  end

  describe 'PATCH /update' do
    it 'admin updates the supervisor' do
      sign_in admin

      patch supervisor_path(supervisor), params: update_supervisor_params
      supervisor.reload

      expect(supervisor.display_name).to eq 'New Name'
      expect(supervisor.email).to eq 'newemail@gmail.com'
      expect(supervisor.role).to eq 'inactive'
    end

    it 'supervisor updates their own name and email' do
      sign_in supervisor

      patch supervisor_path(supervisor), params: update_supervisor_params
      supervisor.reload

      expect(supervisor.display_name).to eq 'New Name'
      expect(supervisor.email).to eq 'newemail@gmail.com'
      expect(supervisor.role).to eq 'supervisor'
    end

    it 'supervisor cannot update another supervisor' do
      supervisor2 = create(:user, :supervisor, display_name: 'Old Name', email: 'oldemail@gmail.com')
      sign_in supervisor

      patch supervisor_path(supervisor2), params: update_supervisor_params
      supervisor2.reload

      expect(supervisor2.display_name).to eq 'Old Name'
      expect(supervisor2.email).to eq 'oldemail@gmail.com'
      expect(response).to redirect_to(root_url)
    end
  end

  def update_supervisor_params
    { user: { email: 'newemail@gmail.com', display_name: 'New Name', role: 'inactive' } }
  end
end
