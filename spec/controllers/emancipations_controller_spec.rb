require "rails_helper"

RSpec.describe EmancipationsController, type: :controller do
  let(:organization) { create(:casa_org) }
  let(:volunteer) { create(:volunteer, :with_casa_cases, casa_org: organization) }
  let(:test_case_category) { create(:casa_case_emancipation_category) }
  subject { post :save, params: params }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(volunteer)
  end

  it "raises Missing param casa_case_id error message" do
    post :save, params: {casa_case_id: "string"}
    expect(response.body).to eq({"error": "Param casa_case_id must be a positive integer"}.to_json)
  end

  it "raises add_option error message" do
    post :save, params: {casa_case_id: "-1"}
    expect(response.body).to eq({"error": "Param casa_case_id must be a positive integer"}.to_json)
  end

  context "empty params" do
    let(:params) { {} }

    it "raises error" do
      expect { subject }.to raise_error(ActionController::UrlGenerationError)
    end
  end

  context "no check_item_id" do
    let(:params) { {casa_case_id: "-1"} }

    it "errors for unfindable casa case" do
      subject
      expect(response.body).to eq({"error": "Could not find case from id given by casa_case_id"}.to_json)
    end
  end

  describe "check_item_action" do
    it "raises missing param error message" do
      post :save, params: {casa_case_id: "1"}
      expect(response.body).to eq({"error": "Missing param check_item_action"}.to_json)
    end
  end

  it "raises param check_item_id error message" do
    post :save, params: {casa_case_id: "1", check_item_action: "1"}
    expect(response.body).to eq({"error": "Missing param check_item_id"}.to_json)
  end

  it "raises must be positive integer error message" do
    post :save, params: {casa_case_id: "1", check_item_action: "1", check_item_id: "-1"}
    expect(response.body).to eq({"error": "Param check_item_id must be a positive integer"}.to_json)
  end

  context "non transitioning case" do
    let(:params) { {casa_case_id: volunteer.casa_cases.first.id} }

    it "errors for unfindable check item" do
      subject
      expect(response.body).to eq({"error": "The current case is not marked as transitioning"}.to_json)
    end
  end

  context "transition ages youth case" do
    let(:casa_case) { volunteer.casa_cases.first }

    before do
      casa_case.update!(transition_aged_youth: true)
    end

    context "with unfindable check item" do
      let(:params) { {casa_case_id: casa_case.id} }

      it "errors for unfindable check item" do
        subject
        expect(response.body).to eq({"error": "Check item action:  is not a supported action"}.to_json)
      end
    end

    context "with check item action and invalid check item id" do
      let(:params) { {casa_case_id: casa_case.id, check_item_action: "add_category", check_item_id: "-1"} }
      it "succeeds" do
        subject
        expect(response.body).to eq({"error": "Could not find option from id given by param check_item_id"}.to_json)
      end
    end
  end
end
