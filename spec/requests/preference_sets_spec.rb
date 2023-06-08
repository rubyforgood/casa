require "rails_helper"

RSpec.describe "PreferenceSets", type: :request do
  describe "#GET Table_State " do
    let!(:supervisor) { create(:supervisor) } # Assuming you have a User factory
    let!(:preference_set) { supervisor.preference_set }
    let!(:table_state) { {"columns" => [{"visible" => "false"}, {"visible" => "true"}, {"visible" => "false"}, {"visible" => "true"}]} }

    before do
      sign_in supervisor
    end

    describe "POST /preference_sets/table_state_update/volunteers_table" do
      subject { post "/preference_sets/table_state_update/volunteers_table", params: {table_name: "volunteers_table", table_state: table_state} }

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
end
