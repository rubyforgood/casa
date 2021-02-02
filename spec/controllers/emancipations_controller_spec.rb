require "rails_helper"

RSpec.describe EmancipationsController, type: :controller do
let(:organization) { create(:casa_org) }
let(:volunteer) {create(:volunteer, :with_casa_cases, casa_org: organization)}
let(:test_case_category) {create(:casa_case_emancipation_category)}

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(volunteer)
  end

  it "raises Missing param casa_case_id error message" do
    post :save, params:{casa_case_id: '1'} 
    expect(response.body).to eq({"error": "Missing param casa_case_id"}.to_json)
  end

  it"raises add_option error message" do
    post :save, params:{casa_case_id: '-1'}
    expect(response.body).to eq({"error": "Param casa_case_id must be a positive integer"}.to_json)
  end

  it "raises add_category error message" do
    post :save, params:{casa_case_id: '1'}
    expect(response.body).to eq({"error": "Missing param check_item_action"}.to_json)
  end

  it "raises param check_item_id error message" do
    post :save, params:{casa_item_id: '1'}
    expect(response.body).to eq({"error": "Missing param check_item_id"}.to_json)
  end

  it "raises must be positive integer error message" do
    post :save, params:{casa_item_id: '-1'}
    expect(response.body).to eq({"error": "Param check_item_id must be a positive integer"}.to_json)
  end
end
