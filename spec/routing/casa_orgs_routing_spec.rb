require 'rails_helper'

RSpec.describe CasaOrgsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/casa_orgs').to route_to('casa_orgs#index')
    end

    it 'routes to #new' do
      expect(get: '/casa_orgs/new').to route_to('casa_orgs#new')
    end

    it 'routes to #show' do
      expect(get: '/casa_orgs/1').to route_to('casa_orgs#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/casa_orgs/1/edit').to route_to('casa_orgs#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/casa_orgs').to route_to('casa_orgs#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/casa_orgs/1').to route_to('casa_orgs#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/casa_orgs/1').to route_to('casa_orgs#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/casa_orgs/1').to route_to('casa_orgs#destroy', id: '1')
    end
  end
end
