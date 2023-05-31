require 'rails_helper'

RSpec.describe "/placement_reports", type: :request do
  let(:admin) { create(:casa_admin) }

  describe 'GET /index' do
    it 'renders a successful response' do
      sign_in admin

      get placement_reports_path, headers: { "ACCEPT" => "*/*" }
      expect(response).to be_successful
    end
  end
end
