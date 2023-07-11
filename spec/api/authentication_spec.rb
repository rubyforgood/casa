require "rails_helper"
require "spec_helper"

RSpec.describe Api::V1::Users::SessionsController , :type => :api do
  let(:casa_org) { create(:casa_org) }
  let(:volunteer) { create(:volunteer, casa_org: casa_org) }

  it "should handle correct sign in" do
    post "/api/v1/users/sign_in", {email: volunteer.email, password: volunteer.password}
   # print last_response.headers
    #print last_response.body
    #expect(last_response.headers).to have_key "Authorization"
    #expect(last_response.headers["Authorization"]).to be_starts_with("Bearer")
    expect(last_response.body).to eq Api::V1::SessionSerializer.new(volunteer).to_json
    expect(last_response.status).to eq 201
    expect(last_response.content_type).to eq("application/json; charset=utf-8")
  end

  it "should handle incorrect sign in" do
    post "/api/v1/users/sign_in", {email: "suzume@tojimari.jp", password: ""}
    body = JSON.parse(last_response.body, symbolize_names: true)
    expect(body.dig(:message)).to eq "Wrong password or username"
    expect(last_response.status).to eq 401
    expect(last_response.content_type).to eq("application/json; charset=utf-8")
  end
end
