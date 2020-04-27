require 'rails_helper'

RSpec.describe '/case_assignments', type: :request do
  describe 'GET /index' do
    context 'with a volunteer signed in' do
      skip 'redirects back to dashboard with an unauthorized notice' do

      end
    end

    context 'with an admin signed in' do
      skip 'renders a successful response' do

      end
    end
  end

  describe 'POST /create' do
    skip 'creates a new case assignment' do

    end
  end

  describe 'DELETE /destroy' do
    skip 'destroys the case assignment' do
      
    end
  end
end
