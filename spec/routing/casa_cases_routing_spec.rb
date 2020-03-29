require 'rails_helper'

# rubocop:todo Metrics/BlockLength
RSpec.describe CasaCasesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/casa_cases').to route_to('casa_cases#index')
    end

    it 'routes to #new' do
      expect(get: '/casa_cases/new').to route_to('casa_cases#new')
    end

    it 'routes to #show' do
      expect(get: '/casa_cases/1').to route_to('casa_cases#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/casa_cases/1/edit').to route_to('casa_cases#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/casa_cases').to route_to('casa_cases#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/casa_cases/1').to route_to('casa_cases#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/casa_cases/1').to route_to('casa_cases#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/casa_cases/1').to route_to('casa_cases#destroy', id: '1')
    end
  end
end
# rubocop:enable Metrics/BlockLength
