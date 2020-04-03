require 'rails_helper'

RSpec.describe '/dashboard', type: :request do
  describe 'GET /show' do
    it 'renders a successful response' do
      sign_in create(:user, :volunteer)

      get root_url

      expect(response).to be_successful
    end
  end
end
