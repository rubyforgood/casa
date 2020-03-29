require 'rails_helper'

# rubocop:todo Metrics/BlockLength
RSpec.describe CaseAssignmentsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/case_assignments').to route_to('case_assignments#index')
    end

    it 'routes to #new' do
      expect(get: '/case_assignments/new').to route_to('case_assignments#new')
    end

    it 'routes to #show' do
      expect(get: '/case_assignments/1').to route_to('case_assignments#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/case_assignments/1/edit').to route_to('case_assignments#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/case_assignments').to route_to('case_assignments#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/case_assignments/1').to route_to('case_assignments#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/case_assignments/1').to route_to('case_assignments#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/case_assignments/1').to route_to('case_assignments#destroy', id: '1')
    end
  end
end
# rubocop:enable Metrics/BlockLength
