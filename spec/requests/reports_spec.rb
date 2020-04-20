require 'rails_helper'

RSpec.describe '/reports', type: :request do
  describe 'GET /index' do
    it 'renders a successful response' do
      sign_in create(:user, :volunteer)

      get reports_url

      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a csv file to download' do
      sign_in create(:user, :volunteer)
      create(:case_contact)

      get report_url(Time.zone.now.to_i, format: :csv)

      expect(response).to be_successful
      expect(response.headers['Content-Disposition']).to include 'attachment; filename="case-contacts-report-'
    end
  end
end
