require 'rails_helper'

RSpec.describe CaseUpdatesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/case_updates').to route_to('case_updates#index')
    end

    it 'routes to #new' do
      expect(get: '/case_updates/new').to route_to('case_updates#new')
    end

    it 'routes to #show' do
      expect(get: '/case_updates/1').to route_to('case_updates#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/case_updates/1/edit').to route_to('case_updates#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/case_updates').to route_to('case_updates#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/case_updates/1').to route_to('case_updates#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/case_updates/1').to route_to('case_updates#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/case_updates/1').to route_to('case_updates#destroy', id: '1')
    end
  end
end
