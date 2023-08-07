require "rails_helper"

RSpec.describe "PreferenceSets", type: :request do
  let!(:supervisor) { create(:supervisor) }
  let!(:preference_set) { supervisor.preference_set }
  let!(:table_state) { {"columns" => [{"visible" => "false"}, {"visible" => "true"}, {"visible" => "false"}, {"visible" => "true"}]} }

  describe "GET /preference_sets/table_state/volunteers_table" do
    subject { get "/preference_sets/table_state/volunteers_table" }

    before do
      sign_in supervisor
      supervisor.preference_set.table_state["volunteers_table"] = table_state
      supervisor.preference_set.save!
    end

    it "returns the table state" do
      subject
      expect(response.body).to eq(table_state.to_json)
    end
  end

  describe "POST /preference_sets/table_state_update/volunteers_table" do
    subject { post "/preference_sets/table_state_update/volunteers_table", params: {table_name: "volunteers_table", table_state: table_state} }
    before do
      sign_in supervisor
    end
    it "updates the table state" do
      subject
      preference_set.reload
      expect(preference_set.table_state["volunteers_table"]).to eq(table_state)
    end

    it "returns a 200 OK status" do
      subject
      expect(response).to have_http_status(:ok)
    end
  end
end
