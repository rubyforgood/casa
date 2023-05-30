require "rails_helper"

RSpec.describe "PreferenceSets", type: :request do
  describe "GET /preference_sets/table_state/volunteers_table" do
    
    let!(:casa_org) { create(:casa_org, ) }
    let!(:supervisor) { create(:supervisor, casa_org: casa_org) }

    let!(:table_state) { { "volunteers_table" => { "columns" => [{ "visible" => true }, { "visible" => false }] } } }
    let!(:supervisor_table_state) { { "volunteers_table" => { "columns" => [{ "visible" => true }, { "visible" => false }] } } }
    let!(:supervisor_preference_set) do
      preference_set = PreferenceSet.create!(user: supervisor)
      puts "Before update: #{preference_set.table_state}"
      preference_set.update!(table_state: supervisor_table_state)
      puts "After update: #{preference_set.reload.table_state}"
      preference_set
    end
    
    

    it "returns http success" do
      sign_in supervisor
      get "/preference_sets/table_state/volunteers_table"
      expect(response).to have_http_status(:success)
    end

    it "returns the correct table state" do
      sign_in supervisor
      get table_state_preference_sets_path(table_name: "volunteers_table")
      
      puts "Response body: #{response.body}"

      expect(response.body).to eq(table_state.to_json)
    end

    it "testing test" do
      sign_in supervisor
      
      puts "Before GET request: #{PreferenceSet.find_by(user: supervisor).reload.table_state}"
      get table_state_preference_sets_path(table_name: "volunteers_table")
      puts "After GET request: #{PreferenceSet.find_by(user: supervisor).table_state}"
      
    end
    
  end
end
