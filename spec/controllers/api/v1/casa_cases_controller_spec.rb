require "rails_helper"
require "spec_helper"

RSpec.describe Api::V1::CasaCasesController, type: :api do
  describe "as a volunteer" do
    describe "GET /api/v1/casa_cases" do
      let(:casa_org) { create(:casa_org) }
      let(:volunteer) { create(:volunteer, casa_org: casa_org) }

      it "should return a list of volunteer's assigned casa cases" do
        casa_cases = create_list(:casa_case, 5, casa_org: casa_org)
        create_list(:casa_case, 2, casa_org: casa_org)
        volunteer.casa_cases << casa_cases
        puts volunteer.casa_cases.inspect
        header("Authorization", "Token token=#{volunteer.token}, email=#{volunteer.email}")
        get "/api/v1/casa_cases"
        expect(last_response.status).to eq 200
        expect(last_response.content_type).to eq("application/json; charset=utf-8")

        body = JSON.parse(last_response.body, symbolize_names: true)
        puts body.inspect
        expect(body.length).to eq 5
        expect(body).to match_array casa_cases.map { |casa_case| Api::V1::CasaCaseSerializer.new(casa_case).as_json }
      end
    end
  end
end
