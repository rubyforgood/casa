require "rails_helper"

RSpec.describe EmancipationsController, type: :controller do
let(:organization) { create(:casa_org) }
let(:volunteer){create(:volunteer, :with_casa_cases, casa_org: organization)}

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(volunteer)
  end

  it "raises add_category error message" do
    test_case_category = create(:casa_case_emancipation_category)
    post :save, params:{casa_case_id: '1'}
    expect(response.body).to eq({"error": "Missing param check_item_action"}.to_json)
  end

  it"raises add_option error message" do
    test_case_category = create(:casa_case_emancipation_category)
    post :save, params: {casa_case_id: '-1'}
    expect(response.body).to eq({"error": "Param casa_case_id must be a positive integer"}.to_json)
  end

  it"raises delete_category error message" do
  end

  it"raises delete_option error message" do
  end

  it"raises set_option error message" do
  end
end

# rescue ActiveRecord::RecordNotFound
#   render json: {error: "Could not find option from id given by param check_item_id"}
# rescue ActiveRecord::RecordNotUnique
#   render json: {error: "Option already added to case"}
# rescue => error
#   render json: {error: error.message}
