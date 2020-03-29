require 'rails_helper'
RSpec.describe SupervisorVolunteersController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/supervisor_volunteers').to route_to('supervisor_volunteers#index')
    end

    it 'routes to #new' do
      expect(get: '/supervisor_volunteers/new').to route_to('supervisor_volunteers#new')
    end

    it 'routes to #show' do
      expect(get: '/supervisor_volunteers/1').to route_to('supervisor_volunteers#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/supervisor_volunteers/1/edit').to route_to('supervisor_volunteers#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/supervisor_volunteers').to route_to('supervisor_volunteers#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/supervisor_volunteers/1').to route_to('supervisor_volunteers#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/supervisor_volunteers/1').to route_to('supervisor_volunteers#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/supervisor_volunteers/1').to route_to('supervisor_volunteers#destroy', id: '1')
    end
  end
end
